module Oceanography
  class MissingValuesMapper

    # Accepts a flat hash removing 'missing_values' property and nulling
    # matching values
    def self.map(doc)
      missing_value = doc["missing_value"]
      if missing_value
        doc.each_with_object({}) do |(key,value), hash|
          if key != "missing_value"
            hash[key] = self.remove_missing_values(missing_value, value)
          end
        end
      else
        doc
      end
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
