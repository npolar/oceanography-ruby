require "oceanography/source/source_tracker"
require "oceanography/version"
require "hashie/mash"

describe Oceanography::SourceTracker do

  logger = Logger.new(STDERR)

  before(:all) do
    logger.level = Logger::INFO
  end

  subject {Oceanography::SourceTracker.new(Hashie::Mash.new({
    log: logger, file: File.expand_path(__FILE__)}))}

  it "should state parser version" do
    expect(subject.source.parser).to match(/#{Oceanography::VERSION}/)
  end

  it "should sha1 hashe file" do
    subject.track_source([{}])
    expect(subject.source.id).to match(/[a-zA-Z0-9]/)
  end

  it "should track numeric variables" do
    subject.track_source([{a: 1.1, b: 0, c: "hej"}])
    expect(subject.source.numerics).to eq([:a, :b])
  end

  it "should add port to url" do
    source_tracker = Oceanography::SourceTracker.new(Hashie::Mash.new({
      log: logger, api_url: "https://localhost:8888/tjoho",
      file: File.expand_path(__FILE__)}))
      expect(source_tracker.source_api_url).to eq("https://localhost:8888/source")
    end

  it "should not add port 80 to url" do
    source_tracker = Oceanography::SourceTracker.new(Hashie::Mash.new({
      log: logger, api_url: "localhost:80/tjoho",
      file: File.expand_path(__FILE__)}))
    expect(source_tracker.source_api_url).to eq("http://localhost/source")
  end
end
