require "spec_helper"
require "oceanography/doc_splitter"
require "uuidtools"

dump_data = eval File.read("spec/oceanography/_data/dump.rb")

describe "Oceanography::DocSplitter.to_docs" do
  logger = Logger.new(STDERR)
  dummy_lambda = lambda { |doc| doc }

  before(:all) do
    logger.level = Logger::INFO
  end

  subject {Oceanography::DocSplitter.new({log: logger}).to_docs(dump_data, dummy_lambda).size}

  it "returns array of correct size" do
    expect(subject).to eq(6)
  end

  context "doc contents" do
    subject {Oceanography::DocSplitter.new({log: logger}).to_docs(dump_data, dummy_lambda)}
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
        expect(doc["max"]).to eq(8)
      end
    end

    it "should have global attributes" do
      subject.each do |doc|
        expect(doc.keys).to include(*dump_data["attributes"].keys.reject {|k| k == "time"})
      end
    end

    it "should add originating file to docs" do
      subject.each do |doc|
        expect(doc["source"]).not_to be_nil
      end
    end

    it "should name 'time' attribute 'measured'" do
      subject.each do |doc|
        expect(doc["measured"]).to eq(dump_data["attributes"]["time"])
      end
    end

    it "should add units hash" do
      subject.each do |doc|
        expect(doc["units"]).to be_kind_of(Hash)
      end
    end
  end
end
