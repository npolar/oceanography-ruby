require "npolar/api/client"

module Oceanography
  class DocsDBPublisher

    attr_reader :client

    def initialize(config)
      if !!config[:url]
        @client = Npolar::Api::Client::JsonApiClient.new(config[:url])
        @client.log = config[:log]
      end
    end

    def post(docs, original_file)
      client.post(docs)
    end
  end
end
