require "uuidtools"
require "json"

module Oceanography
  class DocSplitter

    # Takes a NetCDF hash and splits it into one doc per measurement
    def self.to_docs(nc_hash)
        docs = []
        data = nc_hash["data"]
        variables = nc_hash["variables"]
        attributes = nc_hash["attributes"]
        nr_of_points = variables.reduce(0) {|m, v| [m, v["total"]].max}

        nr_of_points.times do |i|
          doc = {}

          # Attributes
          attributes.each do |key, value|
            doc_key = key
            # Avoid collition with time variable
            doc_key = "measured" if key =~ /^(time|date)$/ui
            doc[doc_key] = value
          end

          # Variable data
          data.each do |key, value|
            doc_value = value
            if (doc_value.respond_to?(:flatten))
              doc_value = doc_value.flatten()
              if (doc_value.size == 1)
                doc_value = doc_value.first
              elsif (doc_value.size == nr_of_points)
                doc_value = doc_value[i]
              end
            end

            # Use time varibale as "measured" if unknown
            if (self.measured_time_unknown?(key, value, doc))
              key = "measured"
            end

            doc[key] = doc_value
          end

          doc["source"] = nc_hash["metadata"]["filename"]

          # Generate a namespaced uuid based on the json string and use that as the ID
          doc["id"] = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, JSON.dump(doc)).to_s

          docs.push(doc)
        end

        docs
    end

    private
    def self.measured_time_unknown?(key, value, doc)
      key == "time" &&
      !value.kind_of?(Array) &&
      doc["measured"] == "unknown"
    end
  end
end
