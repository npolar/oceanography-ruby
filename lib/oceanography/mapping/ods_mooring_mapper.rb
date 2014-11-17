module Oceanography

  class ODSMooringMapper

    MOORING_ID = "(?<mooring>f\\d{1,2})-?(?<deployment>\\d{1,2})?"

    # Accepts flat Hash of key-value pairs
    def map(doc)
      mooring = doc["mooring"]
      if doc["collection"] == "mooring"
        # Is it something like Fram-Strait F14-5 ?
        mooring_data = id_from_mooring(mooring)
        if !mooring_data
          mooring_data = id_from_comments(doc["comments"])
        end
        if !mooring_data
          mooring_data = id_from_source(doc["source"])
        end
        if !mooring_data
          mooring_data = name_from_source(doc["source"])
        end
      end

      doc.merge(mooring_data)
    end

    def id_from_mooring(mooring)
      return nil if mooring.nil?
      match = mooring.match(/#{MOORING_ID}/ui)
      match_data_to_hash(match)
    end

    def id_from_comments(comments)
      return nil if comments.nil?
      match = comments.join.match(/mooring #{MOORING_ID}/ui)
      match_data_to_hash(match)
    end

    def id_from_source(source)
      match = source.match(/#{File::SEPARATOR}#{MOORING_ID}#{File::SEPARATOR}/ui)
      match_data_to_hash(match)
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
