require "spec_helper"
require "oceanography/validation/sanity_validator"
require "logger"

describe Oceanography::SanityValidator do

  subject(:validator) {
    Oceanography::SanityValidator.new({log: Logger.new(STDERR)})
  }

  it "should validate" do
    expect(validator.validate({"measured" => DateTime.civil(2000)})).to be_empty
  end

  it "not should validate future dates" do
    expect(validator.validate({"measured" => DateTime.civil(2300)})).not_to be_empty
  end

  it "not should validate really old dates" do
    expect(validator.validate({"measured" => DateTime.civil(1800)})).not_to be_empty
  end
end
