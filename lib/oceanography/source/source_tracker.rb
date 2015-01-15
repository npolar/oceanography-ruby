require "hashie/mash"
require_relative "../version"
require "json"
require "uri"
require "npolar/api/client"

module Oceanography
  class SourceTracker

    attr_accessor :source, :source_api_url, :source_doc_url
    attr_reader :log, :api_url

    def initialize(config)
      @log = config.log
      @source = Hashie::Mash.new({
        "collection" => "oceanography",
        "parser" => "oceanography-ruby-#{VERSION}",
        "glob" => config.file_path,
        "schema" => config.schema,
        "mappers" => config.mappers,
        })

      @source_api_url = build_source_api_url(config.api_url)
      @api_url = config.api_url
    end

    def track_source(docs, file)
      source.merge!({
        "id" => Digest::SHA1.file(file).hexdigest,
        "file" => File.realpath(file),
        "size" => docs.length,
        "type" => docs.map {|doc| doc["collection"]}.uniq,
        "cruise" => docs.map {|doc| doc["cruise"]}.uniq,
        "measured" => docs.map {|doc| doc["measured"]}.uniq,
        "mooring" => docs.map {|doc| doc["mooring"]}.uniq,
        "station" => docs.map {|doc| doc["station"]}.uniq,
        "original_station" => docs.map {|doc| doc["original_station"]}.uniq
        })

      @source_doc_url = "#{source_api_url}/#{source.id}"
      if source_api_url
        begin
          log.info("Tracking source to #{source_api_url}")
          handle_tracked_source()
          client = api_client(source_api_url)
          client.post(JSON.dump(source))
        rescue => e
          log.error("Source tracking failed unexpectedly: #{e}")
          raise e
        end
      end

      log.info("Track data: #{JSON.dump(source)}")
      source
    end

    private

    def handle_tracked_source()
      source_already_tracked = false
      begin
        client = api_client(source_doc_url)
        old_source = client.get_body(nil)
        source._rev = old_source._rev
        source_already_tracked = true
        log.info("Source already tracked: #{old_source.to_json}")
      rescue => e
        log.debug(e)
        log.info("Source not previously tracked")
      end

      if source_already_tracked
        client = api_client(api_url)
        params = {
          q: "",
          "filter-links.href" => source_doc_url,
          "filter-links.rel" => "source",
          format: "json",
          variant: "array",
          fields: "_id,_rev"
        }
        revs = client.get_body(nil, params)
        log.debug("Revs: #{revs}")
        docs = revs.map do |rev|
          {
            "_id" => rev["_id"],
            "_rev" => rev["_rev"],
            "_deleted" => true
          }
        end
        log.info("Deleting previously parsed docs from current source")
        if !docs.empty?
          client = api_client("#{api_url}/_bulk_docs")
          client.post(docs)
        end
      end
    end

    def api_client(url)
      client = Npolar::Api::Client::JsonApiClient.new(url)
      client.log = log
      client
    end

    def build_source_api_url(api_url)
      source_api_url = nil
      if api_url
        uri = URI(api_url)
        source_api_url = "#{uri.scheme}://#{uri.host}"
        if (uri.port)
          source_api_url += ":#{uri.port}"
        end
        source_api_url += "/source"
      end
      source_api_url
    end
  end
end
