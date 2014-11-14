require "oceanography/mapping/missing_values_mapper"

describe Oceanography::MissingValuesMapper do
  describe "#map" do
    subject(:mapper) { Oceanography::MissingValuesMapper.new }

    context "with 'missing_value'" do
      doc = {
        "missing_value" => -9999,
        "var1" => [1,2,[-9999]]
      }

      it "should remove attribute 'missing_value'" do
        expect(mapper.map(doc)).not_to have_key("missing_value")
      end

      it "should convert 'missing_value' in data to nil" do
        expect(mapper.map(doc)["var1"][2][0]).to be_nil
      end
    end

    context "without 'missing_value'" do
      doc = {
        "var1" => -9999
      }

      it "should return original hash" do
        expect(mapper.map(doc)).to eq(doc)
      end
    end
  end
end
