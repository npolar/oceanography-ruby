module Oceanography

  class KeyValueMapper

    # Accepts flat Hash of key-value pairs
    def self.map(doc)
      doc.each_with_object({}) do |(k,v), hash|
        key = correct_key(k)
        hash[key] = self.value_mapper(k,v)
      end
    end

    def self.correct_key(k)
      case k
        when /^(?<prefix>.*)(?:depth?)$/ui
          ($~[:prefix].empty? ? "" : $~[:prefix] + "_") + "depth"
        when /^original_?station$/ui
          "station"
        when /^(inst_)?type$/ui
          "instrument_type"
        when /^serialnumber$/ui
          "serial_number"
        else k.downcase
      end
    end

    def self.value_mapper(key, value)
      if value.respond_to?(:nan?) && value.nan?
        nil
      elsif value.kind_of?(Array) && value.size == 1
        self.value_mapper(key, value.flatten.first)
      elsif value.respond_to?(:round)
        value.round(5)
      elsif ['measured', 'start_date', 'stop_date'].include?(key)
        y,m,d,h,min,s = *value.fill(0, value.size, 6-value.size)
        y = y == 91 ? 1991 : y
        self.value_mapper(key, DateTime.new(y,m,d,h,min,s))
      elsif value.respond_to?(:iso8601)
        value.iso8601[0..-7]+"Z"
      else
        value
      end
    end
  end
end
