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
  class NetCDF

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
        n.mapper = ClimateForecast.mapper
        n.open(argv[0])
        m = argv[1] ||= "to_a"
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
      if @config.mapper?
        @mapper = @config.mapper
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
        attr_hash[name]=attribute(name)
      end
      if mapper?
        mapper.call(attr_hash)
      else
        attr_hash
      end
    end

    # Map time array (of numbers relative to a starting point) to array of absolute DateTime objects
    # @return [Array<DateTime>] Array of DateTime
    def datetime(timevar_name="time", time_units_attr_name = "units")
      # Problem 0: Identifying the time variable(s), "time" is used as default
      #
      # Problem 1: Variability in the name of the time "units" attribute name
      #
      # Problem 2: Human-created textual variability in the time variable metadata attribute;
      # atm. we simply scan for four digits to extract the starting year

      timevar = nc.var(timevar_name)
      if timevar.nil?
        raise "Time variable #{timevar_name} not found"
      end

      # Look in attribute "units", but fallback to "time" if not set
      time_units_attr = timevar.att(time_units_attr_name)
      if time_units_attr.nil?
        time_units_attr = timevar.att("time")
      end

      time_units = time_units_attr.get

      match = time_units.match(/(?<resolution>\w+)\s+since\s+(?<since>.*)/)
      if not "days" == match[:resolution]
        raise "Only Julian days to DateTime is currently supported"
      end

      year_scan = match[:since].scan(/\d{4}/)
      if not year_scan.size == 1
        raise "Did not find a 4-digit year in #{time_units}"
      end

      year = year_scan[0].to_i

      variable(timevar_name).map {|t|
        if t < 0
          # Negative time since, so we subtract (using +) t from start point to get the number of days elapsed
          t = DateTime.civil(year).jd + t
        end

        DateTime.jd( DateTime.civil(year).jd + t)
      }
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

    # Dump variable data only (similar to ncdump-json format)
    def dump(complete=true)
      if complete == false
        variable_hash
      else
        { "attributes" => attributes,
          "variables" => variables,
          "dimensions" => dimensions,
          "metadata" => metadata
        }.merge(variable_hash)
      end
    end

    # NetCDF metadata
    def metadata
      { "filename" => File.absolute_path(nc.path),
        "sha1" => Digest::SHA1.file(nc.path).hexdigest
      }
      # netcdf version, hidden properties, etc.
    end

    def mapper?
      mapper.respond_to?(:call)
    end

    # @return [Hash] Hash with arrays of variable data
    def data
      var_hash = {}
      nc.var_names.each do |name|
        var_hash[name] = variable(name)
      end
      if mapper?
        mapper.call(var_hash)
      else
        var_hash
      end
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

        # var => NetCDFVar
        # http://www.gfd-dennou.org/arch/ruby/products/ruby-netcdf/Ref_man.html#label:51
        units = nil
        standard_name = nil
        long_name = nil
        fillvalue = nil
        other = {}

        var.att_names.each do |a|
          if a =~ /^unit(s)?$/ui
            units = var.att(a).get
          elsif a =~ /^long(_)?name?$/ui
            long_name = var.att(a).get
          elsif a =~ /^standard(_)?name?$/ui
            standard_name = var.att(a).get
          elsif a =~ /^fill(_)?value?$/ui
            fillvalue = var.att(a).get
          else
            other[a] = get(var.att(a))
          end
        end

        {
          "name" => var.name,
          "type" => var.vartype,
          "typecode" => var.typecode,
          "shape" => var.shape_current,
          "total" => var.get.total,
          "rank" => var.rank,
          "dimensions"=>var.dim_names,
          "units"=>units,
          "long_name"=> long_name,
          "standard_name"=> standard_name,
          "fillvalue" => fillvalue
        }.merge(other)

      }
    end

    def variable_names
      nc.var_names
    end

    protected

    # @param [::NumRu::NetCDFVar|::NumRu::NetCDFAtt] var or attribute

    def get(var)
      if var.nil?
        return nil
      end
      if var.is_a? ::NumRu::NetCDFVar
        type = var.vartype # sfloat, float etc.


      elsif var.is_a? ::NumRu::NetCDFAtt
        type = var.atttype # char
      else
        raise ArgumentError, "Not NetCDFVar or NetCDFAtt"
      end

      v = case type
        when STRING_TYPE_REGEX  then var.get
        when INTEGER_TYPE_REGEX then var.get.to_a.map {|i| i.to_i }
        when FLOAT_TYPE_REGEX then begin

          # The number of dimensions is called the rank (a.k.a. dimensionality).
          # A scalar variable has rank 0, a vector has rank 1 and a matrix has rank 2.


          if var.respond_to?(:rank) and 1 == var.rank
            var.get.to_a.map {|f| f.nan? ? nil : f.to_f}
          elsif var.respond_to?(:rank) and 2 == var.rank and var.get.total == 1
            # Flatten to avoid [[NaN]]
            [var.get.to_a.flatten.map {|f| f.nan? ? nil : f.to_f}]
          else
            var.get.to_a
          end
        end
        else var.get.to_a
      end

      #if type =~ FLOAT_TYPE_REGEX
      #  if not v.all? {|f| f.is_a? Float }
      #    raise "Mixed array, should only be floats: #{v.to_json}"
      #  end
      #end
      v

    end

  end
end
