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
        when /^originalstation$/ui
          "original_station"
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
      else
        value
      end
    end
  end
end
