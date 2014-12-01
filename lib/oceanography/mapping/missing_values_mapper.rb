module Oceanography
  class MissingValuesMapper

    # Accepts a flat hash removing 'missing_values' property and nulling
    # matching values
    def map(doc)
      doc.each_with_object({}) do |(key,value), hash|
        if key != "missing_value"
          hash[key] = remove_missing_values(doc["missing_value"], value)
        end
      end
    end

    # Recursive removal of "missing_value"
    def remove_missing_values(missing_value, value)
      if [99.999, -999, -9999, 9.969209968386869e+36].include?(value) || value == missing_value
        nil
      elsif value.kind_of?(Array)
        value.map { |v| remove_missing_values(missing_value, v) }
      else
        value
      end
    end
  end
end
