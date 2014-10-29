require "oceanography/mapping/key_mapper"

describe Oceanography::KeyMapper do
  describe "#map" do
    subject(:key_mapper) { Oceanography::KeyMapper }

    it "should convert all key to lowercase" do
      expect(key_mapper.map({"UPPER" => nil})).to have_key("upper")
    end

    it "should correct spelling of 'dept' to 'depth'" do
      expect(key_mapper.map({"dept" => nil})).to have_key("depth")
    end

    it "should insert '_' before '*depth'" do

      expect(key_mapper.map({"echodepth" => nil})).to have_key("echo_depth")
    end

    it "should not insert '_' before 'depth'" do
      expect(key_mapper.map({"depth" => nil})).to have_key("depth")
    end

    it "should correct spelling of 'originalstation' to 'original_station'" do
      expect(key_mapper.map({"originalstation" => nil})).to have_key("original_station")
    end
  end
end
