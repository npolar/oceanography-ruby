require "oceanography/mapping/collection_mapper"

describe Oceanography::CollectionMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::CollectionMapper }

    it "should add collection => 'mooring' for docs with property 'mooring'" do
      expect(mapper.map({"mooring" => nil})["collection"]).to eq("mooring")
    end

    it "should add collection => 'cast' for docs with property 'ctd'" do
      expect(mapper.map({"ctd" => nil})["collection"]).to eq("cast")
    end

    it "should add collection => 'cast' for docs with 'intrument_type' => 'ctd'" do
      expect(mapper.map({"ctd" => nil})["collection"]).to eq("cast")
    end

    it "should add collection => 'cast' for docs with '/casts/' in source" do
      expect(mapper.map({"source" => "a/path/casts/nc001.nc"})["collection"]).to eq("cast")
    end

    it "should add collection => 'mooring' for docs with '/moorings/' in source" do
      expect(mapper.map({"source" => "a/path/moorings/nc001.nc"})["collection"]).to eq("mooring")
    end
  end
end