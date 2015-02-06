module Oceanography
  class DocSplitter

    attr_reader :log, :schema

    def initialize(config)
      @log = config[:log]
      @schema = config[:schema]
    end

    # Takes a NetCDF hash and splits it into one doc per measurement
    def to_docs(nc_hash, process)
        attributes = attributes(nc_hash)
        nr_of_points = nr_of_points(nc_hash)
        docs = []

        nr_of_points.times do |i|
          t = Time.now

          doc = attributes
          doc.merge!(data(nc_hash, nr_of_points, i))
          doc["schema"] = schema if !schema.nil?
          doc = process.call(doc, nc_hash)

          log.debug("Splitting took #{((Time.now - t)*1000).round(5)}ms for iteration #{i}/#{nr_of_points-1}")

          docs.push(doc)
        end
        docs
    end

    private

    def nr_of_points(nc_hash)
      nc_hash["data"].reduce(0) {|m, (k,v)|
        s = v.kind_of?(Array) ? v.flatten.size : 0
        [m, s].max
      }
    end

    def attributes(nc_hash)
      attrs = {}
      nc_hash["attributes"].each do |key, value|
        doc_key = key
        doc_value = value
        doc_key = "measured" if key =~ /^(time|date)$/ui
        if (doc_value.kind_of?(Array))
          if doc_value.first.kind_of?(Array)
            doc_value = doc_value.flatten()
          end
          if (doc_value.size == 1)
            doc_value = doc_value.first
          end
        end
        attrs[doc_key] = doc_value
      end
      attrs
    end

    def data(nc_hash, nr_of_points, index)
      data = {}
      nc_hash["data"].each do |key, value|
        doc_value = value
        doc_key = key
        # Same key as time/date in attributes, this overwrites
        doc_key = "measured" if key =~ /^time$/ui
        if (doc_value.kind_of?(Array))
          if doc_value.first.kind_of?(Array)
            doc_value = doc_value.flatten()
          end
          if (doc_value.size == 1)
            doc_value = doc_value.first
          elsif (doc_value.size >= nr_of_points)
            doc_value = doc_value[index]
          end
        end

        data[doc_key] = doc_value
      end
      data
    end
  end
end
