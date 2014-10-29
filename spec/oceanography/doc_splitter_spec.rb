require "spec_helper"
require "oceanography/doc_splitter"
dump_data = eval File.read("spec/oceanography/_data/dump.rb")

describe "Oceanography::DocSplitter.to_docs" do
  subject {Oceanography::DocSplitter.to_docs(dump_data).size}

  it "returns array of correct size" do
    expect(subject).to eq(6)
  end

  context "doc contents" do
    subject {Oceanography::DocSplitter.to_docs(dump_data)}
    it "should have variable data" do
      subject.each do |doc|
        expect(doc.keys).to include(*dump_data["data"].keys)
      end
    end

    it "should have one dimension variable value in each doc" do
      subject.each_with_index do |doc,i|
        expected = dump_data["data"]["one"].flatten.first
        expect(doc["one"]).to eq(expected)
      end
    end

    it "should split max dimension variable values into each doc" do
      subject.each_with_index do |doc,i|
        expected = dump_data["data"]["max"].flatten[i]
        expect(doc["max"]).to eq(expected)
      end
    end

    it "should have global attributes" do
      subject.each do |doc|
        expect(doc.keys).to include(*dump_data["attributes"].keys)
      end
    end
  end
end