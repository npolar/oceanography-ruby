require "spec_helper"
require "oceanography/parser"
require "oceanography/concurrent_file_handler"
require "fileutils"

describe Oceanography::ConcurrentFileHandler do
  NR_OF_THREADS = 4

  after(:all) do
    FileUtils.rm_rf Dir.glob("#{Dir.pwd}/ncdocs_rejected*.json")
  end

  it "should multithread" do
    allow_any_instance_of(Oceanography::Parser).to receive(:parse_files).and_return([])
    file_handler = Oceanography::ConcurrentFileHandler.new({
      file_path: "./spec",
      nr_of_threads: NR_OF_THREADS
    })

    file_handler.parse_files()
  end

  it "should divide files" do
    file_handler = Oceanography::ConcurrentFileHandler.new
    files = Array.new(100) { "dummy/file.nc" }
    divided = file_handler.divide_files(files)
    expect(divided.length).to be NR_OF_THREADS
  end
end
