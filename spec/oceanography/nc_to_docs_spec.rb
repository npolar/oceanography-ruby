require "spec_helper"
require "json"
require "oceanography/nc_to_docs"
require "fileutils"

describe Oceanography::NcToDocs do

  TMP_DIR = "_tmp"

  describe "#parse_files" do
    after(:all) do
      FileUtils.rm_rf(TMP_DIR)
    end

    it "should write files when out_path is given" do
      nc_to_docs = Oceanography::NcToDocs.new({
        out_path: TMP_DIR,
        base_path: "spec",
        mappers: ["KeyValueCorrectionsMapper"]
      })
      nc_to_docs.parse_files()
      expect(Dir.entries(TMP_DIR).size).to be > 2
    end

    it "should POST to API when api_url is given" do
      nc_to_docs = Oceanography::NcToDocs.new({
        api_url: "http://localhost:9393/oceanography",
        base_path: "spec",
        mappers: ["KeyValueCorrectionsMapper"]
      })
      expect(nc_to_docs.docs_db_publisher).to receive(:post)
      nc_to_docs.parse_files()
    end
  end

  describe "#process" do
    dump_data = eval File.read("spec/oceanography/_data/dump.rb")
    subject(:process) { Oceanography::NcToDocs.new().process(dump_data) }

    it "returns array of docs" do
      expect(process).to satisfy {|v| v.is_a?(Array)}
    end

    it "should add UUID id to docs" do
      process.each do |doc|
        expect(UUIDTools::UUID.parse(doc["id"]).valid?).to be
      end
    end
  end
end
