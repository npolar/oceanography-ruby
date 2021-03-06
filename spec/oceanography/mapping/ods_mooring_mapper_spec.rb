require "spec_helper"
require "oceanography/mapping/ods_mooring_mapper"

describe Oceanography::ODSMooringMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::ODSMooringMapper.new }
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
      expect(mapper.map(doc.merge({ "links" => [{"title" => "a/path/f13/nc001.nc", "rel" => "source"}]}))["mooring"]).to eq("F13")
    end

    it "should parse name from source" do
      expect(mapper.map(doc.merge({ "links" => [{"title" => "a/path/fny/nc001.nc", "rel" => "source"}]}))["mooring"]).to eq("FNY")
    end

    it "should add deployment number from mooring" do
      expect(mapper.map(doc.merge({"mooring" => "F11-3"}))["deployment"]).to eq(3)
    end

    it "should add deployment number from source" do
      expect(mapper.map(doc.merge({ "links" => [{"title" => "a/path/f10-1/nc001.nc", "rel" => "source"}]}))["deployment"]).to eq(1)
    end

    it "should add deployment number from string" do
      expect(mapper.map(doc.merge({"mooring" => "Fram-Strait Mooring F13-9"}))["deployment"]).to eq(9)
    end
  end
end
