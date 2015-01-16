require "spec_helper"
require "oceanography/validation/schema_validator"
require "logger"

describe Oceanography::SchemaValidator do

  subject(:validator) {
    Oceanography::SchemaValidator.new(
    {log: Logger.new(STDERR), schema: "spec/oceanography/_data/schema.json"})
  }

  it "should validate" do
    expect(validator.validate({"id" => 1})).not_to be_empty
  end
end
