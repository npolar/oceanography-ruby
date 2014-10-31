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

    it "should correct spelling of 'originalstation' to 'station'" do
      expect(mapper.map({"originalstation" => nil})).to have_key("station")
    end

    it "should correct spelling of 'instrument_type' to 'type'" do
      expect(mapper.map({"instrument_type" => nil})).to have_key("type")
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

    it "should round floating points to a accurracy of 5" do
      expect(mapper.map({"v" => 23.123345546675})["v"]).to eq(23.12335)
    end

    it "should kkep ints as ints" do
      expect(mapper.map({"v" => 1})["v"]).to eq(1)
    end

    it "should convert 'measured', 'start_date' and 'stop_date' date array to iso8601 string" do
      expect(mapper.map({"measured" => [1981,10,11,15,21,0]})["measured"]).to eq("1981-10-11T15:21:00Z")
    end

    it "should convert DateTime to iso8601 string" do
      expect(mapper.map({"time" => DateTime.new(1981,10,11,15,21,0)})["time"]).to eq("1981-10-11T15:21:00Z")
    end
  end
end
