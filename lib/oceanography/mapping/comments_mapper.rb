module Oceanography
  class CommentsMapper

    COMMENT_REGEX = /^comment(\d{2})?$/ui

    # Accepts flat hash merging all 'commentXX's keys to a 'comments' array
    def self.map(doc)
      doc.each_with_object({}) do |(key,value), hash|
        if key =~ COMMENT_REGEX
          hash["comments"] ||= []
          hash["comments"].push(value)
        end
      end
    end
  end
end
