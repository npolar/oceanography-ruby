module Oceanography

  class ODSCollectionMapper

    # Accepts flat Hash of key-value pairs adding collection property
    def map(doc)
      source_link = (doc["links"]||[]).find { |link| link["rel"] == "source" }
      collection = case
        when doc.has_key?("mooring")
          "mooring"
        when doc.has_key?("ctd")
          "cast"
        when doc["instrument_type"] == "ctd"
          "cast"
        when source_link["title"] =~ /\/casts\//ui
          "cast"
        when source_link["title"] =~ /\/moorings\//ui
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
