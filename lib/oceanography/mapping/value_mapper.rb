module Oceanography
  class ValueMapper

    # Accepts flat Hash of key-value pairs
    def self.map(hash)
      mapped = {}
      hash.each do |(k,v)|
        value = self.value_mapper(k,v)
        mapped[k] = value
      end
      mapped
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
