require "spec_helper"
require "oceanography/mapping/comments_mapper"

describe Oceanography::CommentsMapper do
  describe "#process" do
    subject(:mapper) { Oceanography::CommentsMapper.new }
    doc = {
      "comment01" => "First comment",
      "comment02" => "Second comment"
    }
    it "should merge all properties like 'commentXX'" do
      expected = {
        "comments" => ["First comment", "Second comment"]
      }
      expect(mapper.map(doc)).to eq(expected)
    end
  end
end
