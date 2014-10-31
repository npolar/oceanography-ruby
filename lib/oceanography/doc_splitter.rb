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
            doc[key] = doc_value
          end

          # Attributes
          attributes.each do |key, value|
            if !self.netcdf_specific?(key)
              doc_key = "measured" if key == "time"
              doc[doc_key] = value
            end
          end

          doc["source"] = nc_hash["metadata"]["filename"]

          docs.push(doc)
        end

        docs
    end

    def self.netcdf_specific?(key)
      ['sync', 'INST_TYPE', 'createDimension',
        'createVariable', 'close', 'flush'].include?(key)
    end
  end
end
