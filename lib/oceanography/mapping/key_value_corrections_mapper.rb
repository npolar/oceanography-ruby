module Oceanography

  class KeyValueCorrectionsMapper

    # Accepts flat Hash of key-value pairs
    def self.map(doc)
      doc.each_with_object({}) do |(k,v), hash|
        key = correct_key(k)
        hash[key] = self.value_mapper(k,v)
      end
    end

    def self.correct_key(k)
      case k

      when /^(instrument_type|inst_type|type)$/ui
          "instrument_type"
        when /^serial_?number|serie$/ui
          "serial_number"
        else k.downcase
      end
    end

    # Recursive value mapping
    def self.value_mapper(key, value)
      if (value.respond_to?(:nan?) && value.nan?) || value == "unknown"
        nil
      elsif value.kind_of?(Array) && value.size == 1
        self.value_mapper(key, value.flatten.first)
      elsif value.kind_of?(Float)
        value.round(5)
      elsif value.kind_of?(DateTime)
          value.to_time.utc.iso8601
      elsif ['measured', 'start_date', 'stop_date'].include?(key)
        y,m,d,h,min,s = *value.fill(0, value.size, 6-value.size)
        y = y == 91 ? 1991 : y
        self.value_mapper(key, DateTime.new(y,m,d,h,min,s))
      else
        value
      end
    end
  end
end
