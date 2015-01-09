require "npolar/api/client"

module Oceanography
  class DocsDBPublisher

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def post(docs, original_file)
      client = Npolar::Api::Client::JsonApiClient.new(config[:url])
      client.log = config[:log]
      response = client.post(docs)
      validate_response(response)
    end

    private
    def validate_response(response)
      success = false
      if response.is_a? Array
        success = response.all? {|r| success?(r) }
      else
        success = success?(response)
      end

      if !success
        throw "Failed to post to api"
      end
    end

    def success?(response)
      (200..299).include? response.code
    end
  end
end
