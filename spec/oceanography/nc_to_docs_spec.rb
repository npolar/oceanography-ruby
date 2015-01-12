require "spec_helper"
require "json"
require "oceanography/nc_to_docs"
require "fileutils"

describe Oceanography::NcToDocs do

  TMP_DIR = "/tmp/spec_data"

  describe "#parse_files" do
    after(:all) do
      FileUtils.rm_rf(TMP_DIR)
    end

    it "should write files when file_path is given" do
      nc_to_docs = Oceanography::NcToDocs.new({
        out_path: TMP_DIR,
        file_path: "./spec/",
        mappers: ["KeyValueCorrectionsMapper"]
      })
      nc_to_docs.parse_files()
      expect(Dir.entries(TMP_DIR).size).to be > 2
    end

    it "should POST to API when api_url is given" do
      nc_to_docs = Oceanography::NcToDocs.new({
        api_url: "http://localhost:9393/oceanography",
        file_path: "./spec/",
        mappers: ["KeyValueCorrectionsMapper"]
      })
      expect(nc_to_docs.docs_db_publisher).to receive(:post)
      expect(nc_to_docs.source_tracker).to receive(:track_source)
      nc_to_docs.parse_files()
    end
  end
end
