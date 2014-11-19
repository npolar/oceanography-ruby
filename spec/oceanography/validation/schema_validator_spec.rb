require "spec_helper"
require "oceanography/validation/schema_validator"
require "logger"

describe Oceanography::SchemaValidator do

  subject(:validator) {
    Oceanography::SchemaValidator.new(
    {log: Logger.new(STDERR), schema: "spec/oceanography/_data/schema.json"})
  }

  it "should validate" do
    expect(validator.valid?({"id" => 1})).to be false
  end
end
