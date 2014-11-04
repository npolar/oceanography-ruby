require "spec_helper"
require "json"
require "oceanography/nc_to_docs"

describe Oceanography::NcToDocs do
  dump_data = eval File.read("spec/oceanography/_data/dump.rb")

  subject(:process) { Oceanography::NcToDocs.new().process(dump_data) }
  it "returns array of docs" do
    expect(process).to satisfy {|v| v.is_a?(Array)}
  end
end
