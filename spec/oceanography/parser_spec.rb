require "spec_helper"
require "json"
require "oceanography/parser"
require "fileutils"

describe Oceanography::Parser do

  TMP_DIR = "/tmp/spec_data"

  describe "#parse_files" do
    after(:all) do
      FileUtils.rm_rf(TMP_DIR)
    end

    it "should write files when file_path is given" do
      parser = Oceanography::Parser.new({
        out_path: TMP_DIR,
        mappers: ["KeyValueCorrectionsMapper"],
        log: Logger.new(STDERR)
      })
      parser.parse_files(["./spec/oceanography/_data/ods/cast/1981/fs1981_001_ctd_ctd.nc"])
      expect(Dir.entries(TMP_DIR).size).to be > 2
    end

    it "should POST to API when api_url is given" do
      parser = Oceanography::Parser.new({
        api_url: "http://localhost:9393/oceanography",
        mappers: ["KeyValueCorrectionsMapper"],
        log: Logger.new(STDERR)
      })
      expect(parser.docs_db_publisher).to receive(:post)
      parser.parse_files(["./spec/oceanography/_data/ods/cast/1981/fs1981_001_ctd_ctd.nc"])
    end
  end
end
