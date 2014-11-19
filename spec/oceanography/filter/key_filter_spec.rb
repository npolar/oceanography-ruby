require "spec_helper"
require "oceanography/filter/key_filter"

describe Oceanography::KeyFilter do
  describe "#filter" do
    subject(:filter) { Oceanography::KeyFilter.new }
    it "filter 'data_origin'" do
      expect(filter.filter({ "data_origin" => "NPI" }).size).to eq(0)
    end
  end
end
