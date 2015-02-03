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
        collection: "oceanography",
        parser: "oceanography-ruby-#{VERSION}",
        id: Digest::SHA1.file(config.file).hexdigest,
        file: File.realpath(config.file)
        })

      @source_api_url = build_source_api_url(config.api_url)
      @api_url = config.api_url
      @source_doc_url = "#{source_api_url}/#{source.id}"
    end

    def track_source(docs)
      source.merge!({
        size: docs.length,
        type: docs.first["collection"],
        cruise: docs.first["cruise"],
        numerics: variables(docs)
        })

      source.merge!(cast_data(docs))
      source.merge!(mooring_data(docs))

      post_source()

      log.info("Track data: #{JSON.dump(source)}")
      source
    end

    private

    def cast_data(docs)
      if docs.first["collection"] == "cast"
        {
          station: docs.first["station"],
          original_station: docs.first["original_station"],
        }
      else
        {}
      end
    end

    def mooring_data(docs)
      if docs.first["collection"] == "mooring"
        {
          mooring: docs.first["mooring"],
          deployment: docs.first["deployment"],
        }
      else
        {}
      end
    end

    def variables(docs)
      docs.first.each_with_object([]) do |(k,v), var|
        if (v.kind_of?(Numeric))
          var.push(k)
        end
      end
    end

    def post_source()
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
    end

    def handle_tracked_source()
      source_already_tracked = get_rev_if_tracked()

      if source_already_tracked
        client = api_client(api_url)
        params = query_params()
        revs = client.get_body(nil, params)
        log.debug("Revs: #{revs}")

        docs = docs_to_delete(revs)
        log.info("Deleting #{docs.size} previously parsed docs from current source")
        if !docs.empty?
          client = api_client("#{api_url}/_bulk_docs")
          client.post(docs)
        end
      end
    end

    def docs_to_delete(revs)
      revs.map do |rev|
        {
          _id: rev["_id"],
          _rev: rev["_rev"],
          _deleted: true
        }
      end
    end

    def query_params()
      {
        q: "",
        "filter-links.href" => source_doc_url,
        "filter-links.rel" => "source",
        format: "json",
        variant: "array",
        fields: "_id,_rev",
        limit: "all"
      }
    end

    def get_rev_if_tracked()
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
      source_already_tracked
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
