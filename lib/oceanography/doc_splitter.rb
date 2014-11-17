module Oceanography
  class DocSplitter

    # Takes a NetCDF hash and splits it into one doc per measurement
    def to_docs(nc_hash)
        docs = []
        nr_of_points = nc_hash["variables"].reduce(0) {|m, v| [m, v["total"]].max}

        nr_of_points.times do |i|
          doc = {}
          doc.merge!(attributes(nc_hash))
          doc.merge!(data(nc_hash, nr_of_points, i))
          doc.merge!({ "units" => units(nc_hash)})

          doc["source"] = nc_hash["metadata"]["filename"]

          docs.push(doc)
        end

        docs
    end

    private

    def attributes(nc_hash)
      attrs = {}
      nc_hash["attributes"].each do |key, value|
        doc_key = key
        # Avoid collition with time variable
        doc_key = "measured" if key =~ /^(time|date)$/ui
        attrs[doc_key] = value
      end
      attrs
    end

    def data(nc_hash, nr_of_points, index)
      data = {}
      nc_hash["data"].each do |key, value|
        doc_value = value
        if (doc_value.respond_to?(:flatten))
          doc_value = doc_value.flatten()
          if (doc_value.size == 1)
            doc_value = doc_value.first
          elsif (doc_value.size == nr_of_points)
            doc_value = doc_value[index]
          end
        end

        data[key] = doc_value
      end
    end

    def units(nc_hash)
      nc_hash["variables"].reduce({}) do |memo, var|
        memo[var["name"]] = var["units"]
        memo
      end
    end
  end
end
