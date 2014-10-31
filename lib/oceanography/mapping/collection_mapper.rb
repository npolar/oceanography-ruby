module Oceanography

  class CollectionMapper

    # Accepts flat Hash of key-value pairs adding collection property
    def self.map(doc)
      collection = case
        when doc.has_key?("mooring")
          "mooring"
        when doc.has_key?("ctd")
          "cast"
        when doc["instrument_type"] == "ctd"
          "cast"
        when doc["source"] =~ /\/casts\//ui
          "cast"
        when doc["source"] =~ /\/moorings\//ui
          "mooring"
        else
          "unknown"
        end
      doc.merge({
        "collection" => collection
        })
    end
  end
end
