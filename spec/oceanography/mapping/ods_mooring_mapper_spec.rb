require "oceanography/mapping/ods_mooring_mapper"

describe Oceanography::ODSMooringMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::ODSMooringMapper }
    doc = {
      "collection" => "mooring",
      "source" => ""
    }

    it "should keep mooring value if valid id" do
      expect(mapper.map({"mooring" => "F11"}.merge(doc))["mooring"]).to eq("F11")
    end

    it "should parse id from mooring string" do
      expect(mapper.map({"mooring" => "Fram-Strait Mooring F13"}.merge(doc))["mooring"]).to eq("F13")
    end

    it "should parse id from comments" do
      expect(mapper.map({"comments" => ["bla bla mooring f1"]}.merge(doc))["mooring"]).to eq("F1")
    end

    it "should parse id from source" do
      expect(mapper.map(doc.merge({"source" => "a/path/f13/nc001.nc"}))["mooring"]).to eq("F13")
    end

    it "should parse name from source" do
      expect(mapper.map(doc.merge({"source" => "a/path/fny/nc001.nc"}))["mooring"]).to eq("FNY")
    end
  end
end
