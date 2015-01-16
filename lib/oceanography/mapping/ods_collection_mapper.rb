module Oceanography

  class ODSCollectionMapper

    # Accepts flat Hash of key-value pairs adding collection property
    def map(doc)
      collection = case
        when doc.has_key?("mooring")
          "mooring"
        when doc.has_key?("ctd")
          "cast"
        when doc["instrument_type"] == "ctd"
          "cast"
        when doc["links"]["title"] =~ /\/casts\//ui
          "cast"
        when doc["links"]["title"] =~ /\/moorings\//ui
          "mooring"
        else
          nil
        end
      doc.merge({
        "collection" => collection
        })
    end
  end
end
