require "oceanography/mapping/key_value_mapper"

describe Oceanography::KeyValueMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::KeyValueMapper }

    it "should convert all key to lowercase" do
      expect(mapper.map({"UPPER" => nil})).to have_key("upper")
    end

    it "should correct spelling of 'dept' to 'depth'" do
      expect(mapper.map({"dept" => nil})).to have_key("depth")
    end

    it "should insert '_' before '*depth'" do
      expect(mapper.map({"echodepth" => nil})).to have_key("echo_depth")
    end

    it "should not insert '_' before 'depth'" do
      expect(mapper.map({"depth" => nil})).to have_key("depth")
    end

    it "should correct spelling of 'originalstation' to 'original_station'" do
      expect(mapper.map({"originalstation" => nil})).to have_key("original_station")
    end

    it "should correct spelling of 'inst_type' to 'instrument_type'" do
      expect(mapper.map({"inst_type" => nil})).to have_key("instrument_type")
    end

    it "should correct spelling of 'type' to 'instrument_type'" do
      expect(mapper.map({"type" => nil})).to have_key("instrument_type")
    end

    it "should correct spelling of 'serialnumber' to 'serial_number'" do
      expect(mapper.map({"serialnumber" => nil})).to have_key("serial_number")
    end

    it "should unwrap arrays of size 1" do
      expect(mapper.map({"array" => [1]})["array"]).to eq(1)
    end

    it "should unwrap deep arrays of size 1" do
      expect(mapper.map({"array" => [[1]]})["array"]).to eq(1)
    end

    it "should convert NaN to nil" do
      expect(mapper.map({"array" => Float::NAN})["array"]).to eq(nil)
    end
  end
end
