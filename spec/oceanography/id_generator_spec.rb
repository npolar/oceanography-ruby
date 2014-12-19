require "spec_helper"
require "oceanography/id_generator"

describe Oceanography::IdGenerator do

  it "should generate same id give the same input" do
    id_generator = Oceanography::IdGenerator.new("")
    id1 = id_generator.generateId()

    # Reset sequencing
    id_generator = Oceanography::IdGenerator.new("")
    id2 = id_generator.generateId()
    expect(id1).to eq(id2)
  end

  it "should generate sequentail ids" do
    id_generator = Oceanography::IdGenerator.new("")
    id1 = id_generator.generateId()

    # Reset sequencing
    id_generator = Oceanography::IdGenerator.new("")
    id2 = id_generator.generateId()
    expect(id1).to eq(id2)
  end

end
