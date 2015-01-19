module Oceanography

  class ODSMooringMapper

    MOORING_DATA = /(?<mooring_data>f\d{1,2}-\d{1,2})/ui
    MOORING_DATA_FALLBACK = /(?<mooring_data>f\d{1,2})/ui

    # Accepts flat Hash of key-value pairs
    def map(doc)
      if doc["links"]
        source = doc["links"].find { |link| link["rel"] == "source" }["title"]
      end

      if doc["collection"] == "mooring"
        # Is it something like Fram-Strait F14-5 ?
        data = mooring_data(doc, source)
        match = data.match(MOORING_DATA)
        mooring_data = match_data_to_hash(match)
        if !mooring_data
          match = data.match(MOORING_DATA_FALLBACK)
          mooring_data = match_data_to_hash(match)
        end
        if !mooring_data
          mooring_data = name_from_source(source)
        end
        doc.merge!(mooring_data)
      end
      doc
    end

    def mooring_data(doc, source)
      "#{doc['mooring']} #{(doc['comments'] || []).join} #{source}"
    end

    def name_from_source(source)
      match = source.match(/#{File::SEPARATOR}(?<mooring_data>FNY)#{File::SEPARATOR}/ui)
      match_data_to_hash(match)
    end

    def match_data_to_hash(match)
      return nil if match.nil? || match[:mooring_data].nil?
      mooring_data = match[:mooring_data].upcase.split("-")
      hash = {
        "mooring" => mooring_data[0],
      }
      if mooring_data[1]
        hash["deployment"] = mooring_data[1].to_i
      end
      hash
    end
  end
end
