require "nokogiri"

module Oceanography
  class NcML

    def initialize(xml)
      if File.exists? xml
        xml = File.read xml
      end
      @ngd = Nokogiri.XML(xml)
    end


    def attributes
      attributes = {}
      @ngd.xpath("/xmlns:netcdf/xmlns:attribute").map { |e|
        [e.attr("name"), e.attr("value"), e.attr("type")]
      }.each {|name, value, type|
        #p [name,value,type]
        if type =~ /(byte|short|int|long)/
          value = value.split(" ").map {|v|v.to_i}
        elsif type =~ /(float|real|double)/
          value = value.split(" ").map {|v| v.to_f }
        elsif type =~ /(char|string)/ or type.nil? or type.to_s == ""
          value = value.to_s
        else
          raise "Unknown netCDF type: #{type}"
        end
        attributes[name] = value

      }
      attributes
    end

    def dimensions
      @ngd.xpath("/xmlns:netcdf/xmlns:dimension").map { |e|
        [e.attr("name"), e.attr("length"), e.attr("isUnlimited")]
      }.map {|name, length, unlimited|

        unlimited = case unlimited
          when "true" then true
          else false
        end
        { "name" => name, "length" => length.to_i, "unlimited" => unlimited  }
      }
    end

    def variables
      @ngd.xpath("/xmlns:netcdf/xmlns:variable").map { |e|
        [e.attr("name"), e.attr("shape")||"", e.attr("type")]
      }.map {|name, shape, type|
        { "name" => name, "shape" => shape.split(" "), "type" => type  }
      }
    end


    #{
    #    "name"=>"prof_S",
    #    "type"=>"float",
    #    "typecode"=>5,
    #    "shape"=>[
    #        55,
    #        164472
    #    ],
    #    "total"=>9045960,
    #    "rank"=>2,
    #    "dimensions"=>[
    #        "iDEPTH",
    #        "iPROF"
    #    ],
    #    "units"=>"psu",
    #    "long_name"=>"salinity",
    #    "standard_name"=>nil,
    #    "fillvalue"=>nil,
    #    "missing_value"=>[
    #        -9999.0
    #    ],
    #    "_FillValue"=>[
    #        -9999.0
    #    ]
    #}



  end
end
