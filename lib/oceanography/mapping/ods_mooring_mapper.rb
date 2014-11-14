module Oceanography

  class ODSMooringMapper

    MOORING_ID = "(?<mooring>f\\d{1,2})(?:-\\d{1,2})?"

    # Accepts flat Hash of key-value pairs
    def self.map(doc)
      mooring = doc["mooring"]
      if doc["collection"] == "mooring" && !(mooring =~ /^#{MOORING_ID}$/ui)
        # Is it something like Fram-Strait F14-5 ?
        mooring = self.id_from_mooring(mooring)
        if !mooring
          mooring = self.id_from_comments(doc["comments"])
        end
        if !mooring
          mooring = self.id_from_source(doc["source"])
        end
        if !mooring
          mooring = self.name_from_source(doc["source"])
        end
      end

      if mooring
        doc["mooring"] = mooring.upcase
      end
      doc
    end

    def self.id_from_mooring(mooring)
      return nil if mooring.nil?
      match = mooring.match(/#{MOORING_ID}/ui)
      match ? match[:mooring] : nil
    end

    def self.id_from_comments(comments)
      return nil if comments.nil?
      match = comments.join.match(/mooring #{MOORING_ID}/ui)
      match ? match[:mooring] : nil
    end

    def self.id_from_source(source)
      match = source.match(/#{File::SEPARATOR}#{MOORING_ID}#{File::SEPARATOR}/ui)
      match ? match[:mooring] : nil
    end

    def self.name_from_source(source)
      match = source.match(/#{File::SEPARATOR}(?<mooring>FNY)#{File::SEPARATOR}/ui)
      match ? match[:mooring] : nil
    end

  end
end
