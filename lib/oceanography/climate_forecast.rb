module Oceanography

  class ClimateForecast

    # Climate and forecast conventions variable and attribute mappper for common synonyms
    def self.mapper
      lambda {|hash|
        mapped = {}
        hash.each do |k,v|
          key = case k
            when /^(temperature|temp|t)$/ui
              "sea_water_temperature"
            when /^(pressure|pres|p)$/ui
              "sea_water_pressure"
            else k.downcase
          end

          mapped[key]=v


        end
        mapped
      }
    end

  end
end
