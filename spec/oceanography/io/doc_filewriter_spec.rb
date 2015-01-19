require "spec_helper"
require "oceanography/io/doc_filewriter"

describe Oceanography::DocFileWriter do

  after(:all) do
    FileUtils.rm_rf(CONFIG[:out_path])
  end

  it "should write something" do
    CONFIG = {
      out_path: "/tmp/spec_data_2",
      log: Logger.new(STDERR)
    }
    
    fw = Oceanography::DocFileWriter.new(CONFIG)
    fw.write([{"id" => "1"}], "/a/path/file.nc")
    expect(Dir.entries(CONFIG[:out_path]).size).to be > 0
  end

end
