require "oceanography/nchash_processing/merge_comments"

describe Oceanography::MergeCommentsProcessor do
  describe "#process" do
    subject(:post_processor) { Oceanography::MergeCommentsProcessor }
    nc_hash = {
      "attributes" => {
        "comment01" => "First comment",
        "comment02" => "Second comment"
      }
    }
    it "should merge all attributes like 'commentXX'" do
      expected = {
        "attributes" => {
          "comments" => ["First comment", "Second comment"]
        }
      }
      expect(post_processor.process(nc_hash)).to eq(expected)
    end
  end
end
