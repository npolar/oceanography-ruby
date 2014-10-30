module Oceanography
  class MissingValuesProcessor

    # Takes a nchash (typically generated with netcdf.rb) and apply
    # post processing removing 'missing_values'
    def self.process(nc_hash)
      missing_value = nc_hash["attributes"]["missing_value"]
      attributes = nc_hash["attributes"].reject {|key| key == "missing_value"}
      if missing_value
        data = nc_hash["data"].each_with_object({}) do |(key,value), hash|
          hash[key] = self.remove_missing_values(missing_value, value)
        end
      end
      nc_hash.merge({
        "attributes" => attributes,
        "data" => data || nc_hash["data"]
        })
    end

    def self.remove_missing_values(missing_value, value)
      if value == missing_value
        nil
      elsif value.respond_to?(:map)
        value.map { |v| self.remove_missing_values(missing_value, v) }
      else
        value
      end
    end
  end
end
