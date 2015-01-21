require "spec_helper"
require "oceanography/mapping/ods_instrument_type_mapper"

describe Oceanography::ODSInstrumentTypeMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::ODSInstrumentTypeMapper.new }

    it "should merge ctd with instrument_type if set" do
      expect(mapper.map({
        "ctd" => "seabird",
        "instrument_type" => "ctd"
      })["instrument_type"]).to eq("seabird ctd")
    end

  end
end
