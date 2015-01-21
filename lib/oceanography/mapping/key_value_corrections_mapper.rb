module Oceanography

  class KeyValueCorrectionsMapper

    # Accepts flat Hash of key-value pairs
    def map(doc, nc_hash = {})
      doc.each_with_object({}) do |(k,v), hash|
        key = k
        value = v
        if (k =~ /^serial_?number|serie$/ui)
          key = "serial_number"
          value = v.to_s
        elsif (k =~ /^(inst_type|type)$/ui)
          key = "instrument_type"
          value = instrument_type(value)
        elsif (k =~ /^((original_?)?station)$/ui)
          value = v.to_s
        elsif k =~ /^cruise$/ui
          match = v.match(/^fs(?<cruise>\d{4}(?:-\d)?)$/ui)
          value = match ? "Framstrait-" + match[:cruise] : v
        end
        key = correct_key(key)
        hash[key] = value_mapper(key,value)
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
      if nil_value?(value)
        nil
      elsif flatten_array?(key, value)
        value_mapper(key, value.flatten.first)
      elsif value.kind_of?(Float)
        value.round(5)
      elsif value.kind_of?(DateTime)
        value.to_time.utc.iso8601
      elsif date_array?(key, value)
        map_date_array(key, value)
      else
        value
      end
    end

    def nil_value?(value)
      (value.respond_to?(:nan?) && value.nan?) || value == "unknown"
    end

    def flatten_array?(key, value)
      value.kind_of?(Array) && value.size == 1 && !["links", "comments"].include?(key)
    end

    def date_array?(key, value)
      key =~ /^(measured|start_date|stop_date)$/ui && value.is_a?(Array)
    end

    def map_date_array(key, value)
      # Possible formats: [2001, 01, 13, 23, 59, 59], [2001, 01, 13], [01, 13, 2001]
      # assume size 3, year last
      d,m,y,h,min,s = *value.fill(0, value.size, 6-value.size)
      if (value.first > 60) # year first
        y,d = d,y
      end
      y = y == 91 ? 1991 : y
      value_mapper(key, DateTime.new(y,m,d,h,min,s))
    end

    # instrument_type can be String or [nil, "typ", nil]
    def instrument_type(value)
      if value.kind_of?(Array)
        value = value.find { |v| !v.nil? }
      end
      value.nil? ? nil : value.to_s
    end
  end
end
