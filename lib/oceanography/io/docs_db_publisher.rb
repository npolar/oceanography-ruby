require "npolar/api/client"
require_relative "../parsing_error"

module Oceanography
  class DocsDBPublisher

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def post(docs)
      client = Npolar::Api::Client::JsonApiClient.new(config[:url])
      client.log = config[:log]
      response = client.post(docs)
      validate_response(response)
    end

    private
    def validate_response(response)
      success = false
      if response.is_a? Array
        errors = response.select {|r| !success?(r) }
        success = errors.empty?
      else
        success = success?(response)
        if !success
          errors = [response]
        end
      end

      if !success
        #response_body, #response_code, #effective_url
        errors.uniq! { |e| e.code }
        errors = errors.map { |e|
          "Could not post to #{e.effective_url} got HTTP #{e.response_code}: #{e.response_body}"
        }
        raise ParsingError.new(errors), "Could not post to api"
      end
    end

    def success?(response)
      (200..299).include? response.code
    end
  end
end
