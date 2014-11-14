module Oceanography

  class ODSInstrumentTypeMapper

    # Accepts flat Hash of key-value pairs
    def map(doc)
      ctd = doc["ctd"]
      instrument_type = doc["instrument_type"] || ""

      if instrument_type == "ctd" && !ctd.nil?
        instrument_type.prepend(ctd + " ")
      end
      doc.delete("ctd")
      doc
    end
  end
end
