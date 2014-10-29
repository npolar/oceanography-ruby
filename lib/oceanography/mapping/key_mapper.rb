module Oceanography

  class KeyMapper

    # Accepts flat Hash of key-value pairs
    def self.map(hash)
      mapped = {}
      hash.each do |(k,v)|
        key = case k
        when /^(?<prefix>.*)(?:depth?)$/ui
            ($~[:prefix].empty? ? "" : $~[:prefix] + "_") + "depth"
          when /^originalstation$/ui
            "original_station"
          else k.downcase
        end

        mapped[key]=v

      end
      mapped
    end
  end
end
