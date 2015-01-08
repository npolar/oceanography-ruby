require "spec_helper"
require "oceanography/id_generator"

describe Oceanography::IdGenerator do

  it "should generate sequentail ids" do
    id_generator = Oceanography::IdGenerator.new()
    id1 = id_generator.generateId()
    id2 = id_generator.generateId()
    puts id1
    expect(id1).not_to eq(id2)
    #only last bit should differ
    expect(id1[0..-2]).to eq(id2[0..-2])
  end

  it "should do base conversion" do
    id_generator = Oceanography::IdGenerator.new()

    expect(id_generator.base10toBase64(127)).to eq("AAB_")
  end

end
