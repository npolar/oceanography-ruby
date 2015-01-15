module Oceanography

  class ODSMooringMapper

    MOORINGid = "(?<mooring>f\\d{1,2})-?(?<deployment>\\d{1,2})?"

    # Accepts flat Hash of key-value pairs
    def map(doc)
      if doc["collection"] == "mooring"
        # Is it something like Fram-Strait F14-5 ?
        match = mooring_data(doc).match(/#{MOORINGid}/ui)
        mooring_data = match_data_to_hash(match)
        if !mooring_data
          mooring_data = name_from_source(doc["source"])
        end
        doc.merge!(mooring_data)
      end
      doc
    end

    def mooring_data(doc)
      (doc["mooring"] || "") + (doc["comments"] || []).join + doc["source"]
    end

    def name_from_source(source)
      match = source.match(/#{File::SEPARATOR}(?<mooring>FNY)#{File::SEPARATOR}/ui)
      match_data_to_hash(match)
    end

    def match_data_to_hash(match)
      return nil if match.nil?
      hash = {}
      hash["mooring"] = match[:mooring].upcase if match.names.include?("mooring")
      hash["deployment"] = match[:deployment].to_i if match.names.include?("deployment")
      hash
    end
  end
end
