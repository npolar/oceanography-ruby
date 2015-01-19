require "spec_helper"
require "oceanography/io/docs_db_publisher"

describe Oceanography::DocsDBPublisher do

  CONFIG = {
    url: "http://localhost/dummy/api",
    log: Logger.new(STDERR)
  }

  it "should try to post" do
    api = Oceanography::DocsDBPublisher.new(CONFIG)

    expect { api.post([{"id" => "1"}]) }.to raise_error
  end

end
