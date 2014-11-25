module Oceanography

  class KeyValueCorrectionsMapper

    # Accepts flat Hash of key-value pairs
    def map(doc)
      doc.each_with_object({}) do |(k,v), hash|
        key = k
        value = v
        if (k =~ /^serial_?number|serie$/ui)
          key = "serial_number"
          value = v.to_s
        elsif (k =~ /^(inst_type|type)$/ui)
          key = "instrument_type"
          value = instrument_type(value)
        end
        key = correct_key(key)
        hash[key] = value_mapper(key,v)
      end
    end

    def correct_key(k)
      case k
        when /^originalstation$/ui
          "original_station"
        else k.downcase
      end
    end

    # Recursive value mapping
    def value_mapper(key, value)
      if (value.respond_to?(:nan?) && value.nan?) || value == "unknown"
        nil
      elsif value.kind_of?(Array) && value.size == 1
        value_mapper(key, value.flatten.first)
      elsif value.kind_of?(Float)
        value.round(5)
      elsif value.kind_of?(DateTime)
        value.to_time.utc.iso8601
      elsif key =~ /^(measured|start_date|stop_date)$/ui && value.is_a?(Array)
        # Possible formats: [2001, 01, 13, 23, 59, 59], [2001, 01, 13], [01, 13, 2001]
        if (value.first > 60) # year first
          y,m,d,h,min,s = *value.fill(0, value.size, 6-value.size)
        else # assume size 3, year last
          d,m,y,h,min,s = *value.fill(0, value.size, 6-value.size)
        end
        y = y == 91 ? 1991 : y
        value_mapper(key, DateTime.new(y,m,d,h,min,s))
      else
        value
      end
    end

    # instrument_type can be String or [nil, "typ", nil]
    def instrument_type(value)
      if value.kind_of?(Array)
        value.find { |v| v.kind_of?(String) }
      else
        value
      end
    end
  end
end
