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
          doc.merge!(attributes)

          docs.push(doc)
        end

        docs
    end
  end
end
