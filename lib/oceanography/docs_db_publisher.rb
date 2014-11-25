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
      response = client.post(docs)
      if response.is_a? Array
        response.all? {|r| success?(r) }
      else
        success?(response)
      end
    end

    private
    def success?(response)
      (200..299).include? response.code
    end
  end
end
