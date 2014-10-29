require "spec_helper"
require "json"
require "oceanography/nc_to_json"

describe Oceanography::NcToJson do
  dump_data = eval File.read("spec/oceanography/_data/dump.rb")

  subject(:process) { Oceanography::NcToJson.new().process(dump_data) }
  it "returns json" do
    expect(process).to satisfy {|v| !!JSON.parse(v)}
  end
end
