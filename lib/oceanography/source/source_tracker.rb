require "hashie/mash"
require_relative "../version"
require "json"
require "uri"
require "npolar/api/client"

module Oceanography
  class SourceTracker

    attr_accessor :source
    attr_reader :uri, :log

    def initialize(config)
      if config.api_url?
        @uri = URI.join("http://#{URI(config.api_url).host}", "/source")
      end

      @log = config.log
      @source = Hashie::Mash.new({
        "collection" => "oceanography",
        "parser" => "oceanography-ruby-#{VERSION}",
        "glob" => config.file_path,
        "schema" => config.schema,
        "mappers" => config.mappers.to_s
        })
    end

    def track_source(docs, file)
      source.merge!({
        "file" => file,
        "total" => docs.length,
        "type" => docs[0]["collection"],
        "id" => Digest::SHA1.file(file).hexdigest
        })

        if (uri != nil)
          client = Npolar::Api::Client::JsonApiClient.new(uri)
          client.post(JSON.dump(source))
        end

        log.info("Track data: #{JSON.dump(source)}")
        source
    end
  end
end
