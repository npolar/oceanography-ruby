require "oceanography/source/source_tracker"
require "oceanography/version"
require "hashie/mash"

describe Oceanography::SourceTracker do

  logger = Logger.new(STDERR)

  before(:all) do
    logger.level = Logger::INFO
  end

  subject {Oceanography::SourceTracker.new(Hashie::Mash.new({
    log: logger}))}

  it "should state parser version" do
    expect(subject.source.parser).to match(/#{Oceanography::VERSION}/)
  end

  it "should sha1 hashe file" do
    subject.track_source([], File.expand_path(__FILE__))
    expect(subject.source.id).to match(/[a-zA-Z0-9]/)
  end
end
