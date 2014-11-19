module Oceanography
  class KeyFilter

    def initialize()
      @key_blacklist = ["data_origin"]
    end

    def filter(doc)
      doc.reject do |k,v|
        @key_blacklist.include?(k)
      end
    end
  end
end
