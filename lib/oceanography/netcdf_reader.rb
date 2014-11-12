require "logger"
require "time"
require "json"
require "tempfile"

require "numru/netcdf"
require "numru/netcdf_miss"
require "hashie/mash"

module Oceanography

  # Oceanography::NetCDF is a simple wrapper for NumRu::NetCDF, built to convert
  # oceanography data to and from JSON
  class NetCDFReader

    # Regexes for CDL data types
    # http://www.unidata.ucar.edu/software/netcdf/docs/cdl_data_types.html
    # Permissive matching to match also NetCDF-4 u* and *64 types
    FLOAT_TYPE_REGEX = /(float|real|double)/
    INTEGER_TYPE_REGEX = /(byte|short|int|long)/
    STRING_TYPE_REGEX = /(char|string)/

    # Default config
    # log, precision, mapper...
    CONFIG = {}

    include NumRu

    # [Hash|Hashie::Mash] config
    attr_accessor :config

    # [NumRu::NetCDF] nc http://www.gfd-dennou.org/arch/ruby/products/ruby-netcdf/Ref_man.html#label:9
    attr_reader :nc

    # [Logger] log
    attr_accessor :config, :log

    # [Proc] mapper lambda that receives a key-value Hash of attributes or data (variable hash) for remapping
    # See #attributes and #variables
    attr_accessor :mapper

    def self.ncjson(argv=ARGV)
      begin
        if argv.size < 1 or not File.exists?(argv[0])
          raise "Error: missing netCDF input file\n"
        end
        n = Oceanography::NetCDF.new
        n.log = Logger.new(STDERR)
        n.open(argv[0])
        m = argv[1] ||= "hash"
        puts JSON.pretty_generate(n.send(m.to_sym))
      rescue => e
        STDERR.write(e.message+"\n")
        exit(-1)
      end
    end

    def initialize(config = CONFIG)
      @config = Hashie::Mash.new(config)
      if @config.log?
        @log = @config.log
      else
        @log = Logger.new("/dev/null")
      end
    end

    # Magic accessor, allows reading variables and attributes using .name syntax (with preference to variables)
    def method_missing(m, *args, &block)
      variable(m.to_s) or attribute(m.to_s)
    end

    # Set NetCDF object (automagic opening if filename)
    def nc=(filename_or_object, mode="r", shared=false)
      if filename_or_object.is_a? NumRu::NetCDF
        @nc = filename_or_object
      elsif File.exists? filename_or_object
        @nc = ::NumRu::NetCDF.open(filename_or_object, mode, shared)
      else
        raise ArgumentError "Not NetCDF object or file: #{filename_or_object}."
      end
      self
    end
    alias :open :nc=

    # Get value of named attribute
    # @return [Array|String]
    def attribute(name)
      attr = nc.att(name)
      get(attr)
    end

    # Attributes Hash
    # @return [Hash]
    def attributes
      attr_hash = {}
      nc.att_names.each do |name|
        attr_hash[name] = attribute(name)
      end
      attr_hash
    end

    # Dimensions Hash
    def dimensions
      nc.dims.map {|d|
        { "name" => d.name,  #:length, :name=, :name, :unlimited?, :length_ul0
          "length" => d.length,
          "unlimited" => d.unlimited?
        }
      }
    end

    # Dump complete hash of nc contents
    def hash()
      {
          "attributes" => attributes,
          "variables" => variables,
          "dimensions" => dimensions,
          "metadata" => metadata,
          "data" => variable_hash
        }
    end

    # NetCDF metadata
    def metadata
      { "filename" => File.absolute_path(nc.path),
        "sha1" => Digest::SHA1.file(nc.path).hexdigest
      }
      # netcdf version, hidden properties, etc.
    end

    # @return [Hash] Hash with arrays of variable data
    def data
      var_hash = {}
      variable_names.each do |name|
        var_hash[name] = variable(name)
      end
      var_hash
    end
    alias :variable_hash :data

    # Get value of (1) named variable
    def variable(name)
      var = nc.var(name) # NetCDFVar
      get(var)
    end

    # Variables metadata
    # @return [Hash]
    def variables
      nc.vars.map {|var|

        attrs = variable_attributes(var)

        {
          "name" => var.name,
          "type" => var.vartype,
          "typecode" => var.typecode,
          "shape" => var.shape_current,
          "total" => var.get.total,
          "rank" => var.rank,
          "dimensions"=>var.dim_names
        }.merge(attrs)
      }
    end

    def variable_attributes(var)
      # var => NetCDFVar
      # http://www.gfd-dennou.org/arch/ruby/products/ruby-netcdf/Ref_man.html#label:51
      attrs = {}

      var.att_names.each do |a|
        key = case a
          when /^unit(s)?$/ui
              "units"
          when /^long(_)?name?$/ui
              "long_name"
          when /^standard(_)?name?$/ui
              "standard_name"
          when /^fill(_)?value?$/ui
              "fillvalue"
          else
            a
        end
        attrs[key] = get(var.att(a))
      end
      attrs
    end

    def variable_names
      nc.var_names
    end

    protected

    # @param [::NumRu::NetCDFVar|::NumRu::NetCDFAtt] var or attribute
    def get(var)
      if var.respond_to?(:vartype)
        type = var.vartype
      elsif var.respond_to?(:atttype)
        type = var.atttype
      else
        raise ArgumentError, "Not NetCDFVar or NetCDFAtt"
      end

      if var.kind_of?(NetCDFVar) && var.name == "time"
        type = :timevar
      end

      #var.get : String or an NArray object (NOTE: even a scalar is returned as an NArray of length 1)
      v = case type
        when STRING_TYPE_REGEX  then var.get
        when INTEGER_TYPE_REGEX then var.get.to_a.map {|i| i.to_i }
        when FLOAT_TYPE_REGEX then var.get.to_a.map {|f| f.respond_to?(:to_f) ? f.to_f : f[0].to_f }
        when :timevar then float_time_to_datetime(var)
        else var.get.to_a
      end

      v
    end

    # Map time array (of numbers relative to a starting point) to array of absolute DateTime objects
    # @return [Array<DateTime>] Array of DateTime
    def float_time_to_datetime(timevar)
      # Problem 0: Identifying the time variable(s), "time" is used as default
      #
      # Problem 1: Variability in the name of the time "units" attribute name
      #
      # Problem 2: Human-created textual variability in the time variable metadata attribute;
      # atm. we simply scan for four digits to extract the starting year

      # Look in attribute "units", but fallback to "time" if not set
      units_string = (timevar.att("units") || timevar.att("time")).get
      year = year_from_units_string(units_string)

      timevar.get.to_a.map do |t|
        return nil if t.nan?
        if t < 0
          # Negative time since, so we subtract (using +) t from start point to get the number of days elapsed
          t = DateTime.civil(year).jd + t
        end

        DateTime.jd( DateTime.civil(year).jd + t)
      end
    end

    def year_from_units_string(time_units)
      match = time_units.match(/(?<resolution>\w+)\s+since\s+(?<since>.*)/)
      if not "days" == match[:resolution]
        raise "Only Julian days to DateTime is currently supported"
      end

      year_scan = match[:since].scan(/\d{4}/)
      if not year_scan.size == 1
        raise "Did not find a 4-digit year in #{time_units}"
      end

      year_scan[0].to_i
    end
  end
end
