require "oceanography/mapping/value_mapper"

describe Oceanography::ValueMapper do
  describe "#map" do
    subject(:value_mapper) { Oceanography::ValueMapper }

    it "should unwrap arrays of size 1" do
      expect(value_mapper.map({"array" => [1]})["array"]).to eq(1)
    end

    it "should unwrap deep arrays of size 1" do
      expect(value_mapper.map({"array" => [[1]]})["array"]).to eq(1)
    end

    it "should convert NaN to nil" do
      expect(value_mapper.map({"array" => Float::NAN})["array"]).to eq(nil)
    end
  end
end
