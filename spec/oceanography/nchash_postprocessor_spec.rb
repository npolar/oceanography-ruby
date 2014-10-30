require "oceanography/nchash_postprocessor"

describe Oceanography::NcHashPostProcessor do
  describe "#process" do
    subject(:post_processor) { Oceanography::NcHashPostProcessor }

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
  end
end
