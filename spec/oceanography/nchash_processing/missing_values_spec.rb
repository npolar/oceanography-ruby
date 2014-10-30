require "oceanography/nchash_processing/missing_values"

describe Oceanography::MissingValuesProcessor do
  describe "#process" do
    subject(:post_processor) { Oceanography::MissingValuesProcessor }

    context "with 'missing_value'" do
      nc_hash = {
        "attributes" => {
          "missing_value" => -9999
        },
        "data" => {
          "var1" => [1,2,[-9999]]
        }
      }

      it "should remove attribute 'missing_value'" do
        expect(post_processor.process(nc_hash)["attributes"]).not_to have_key("missing_value")
      end

      it "should convert 'missing_value' in data to nil" do
        expect(post_processor.process(nc_hash)["data"]["var1"][2][0]).to be_nil
      end
    end

    context "without 'missing_value'" do
      nc_hash = {
        "attributes" => {},
        "data" => {
          "var1" => [1,2,-9999]
        }
      }

      it "should return original hash" do
        expect(post_processor.process(nc_hash)).to eq(nc_hash)
      end
    end
  end
end
