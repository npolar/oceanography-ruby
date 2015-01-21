module Oceanography

  class ODSClimateForecastMapper

    # Climate and forecast conventions variable and attribute mappper for common synonyms
    # @see http://cfconventions.org/Data/cf-standard-names/27/build/cf-standard-name-table.html
    def map(doc, nc_hash = {})
      mapped = {}
      units = units(nc_hash)
      doc.each do |k,v|
        key = case k
          when /^(temperature|temp|t)$/ui
            "sea_water_temperature"
          when /^(pressure|pres|p)$/ui
            "sea_water_pressure_due_to_sea_water"
          when /^(salinity|s)$/ui
            "sea_water_salinity"
          when /^dire$/ui
            "direction_of_sea_water_velocity"
          when /^uvel$/ui
            "eastward_sea_water_velocity"
          when /^vvel$/ui
            "northward_sea_water_velocity"
          when /^conductivity$/ui
            "sea_water_electrical_conductivity"
          when /^(water_?depth|echo_?depth)$/ui
            "sea_floor_depth_below_sea_surface"
          when /^(dept|instrdepth)$/ui
            "depth"
          else k.downcase
        end
        unit = units ? units[k] : nil
        if unit
          converted = convert_units(key, v, unit)
          mapped[key] = converted["value"]
        else
          mapped[key] = v
        end
      end
      mapped
    end

    def convert_units(key, value, unit)
      converted = {
        "value" => value,
        "unit" => unit
      }
      if value
        if unit =~ /cm\/s/ui
          converted["value"] = (value / 100).round(5)
          converted["unit"] = "m/s"
        elsif unit =~ /mS\/cm/ui
          converted["value"] = (value / 10).round(5)
          converted["unit"] = "S/m"
        end
      end
      converted
    end

    def units(nc_hash)
      (nc_hash["variables"] || []).reduce({}) do |memo, var|
        memo[var["name"]] = var["units"]
        memo
      end
    end
  end
end
