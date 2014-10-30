module Oceanography
  class MergeCommentsProcessor

    COMMENT_REGEX = /^comment(\d{2})?$/ui

    # Takes a nchash (typically generated with netcdf.rb) and apply
    # post processing merging all 'commentX's
    def self.process(nc_hash)
      if !!nc_hash["attributes"].keys.detect{ |k| k.to_s =~ COMMENT_REGEX }
        attributes = nc_hash["attributes"].each_with_object({}) do |(key,value), hash|
          if key =~ COMMENT_REGEX
            hash["comments"] ||= []
            hash["comments"].push(value)
            hash.delete(key)
          end
        end
      end
      nc_hash.merge({
        "attributes" => attributes || nc_hash["attributes"]
        })
    end
  end
end
