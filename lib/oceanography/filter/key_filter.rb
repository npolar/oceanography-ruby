module Oceanography
  class KeyFilter

    def initialize()
      @key_blacklist = ["data_origin", "units"]
    end

    def filter(doc)
      doc.reject do |k,v|
        @key_blacklist.include?(k) || v.nil?
      end
    end
  end
end
