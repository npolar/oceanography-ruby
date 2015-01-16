require "logger"
require "hashie/mash"
require "fileutils"
require "uuidtools"
require "json"
require "require_all"
require_rel "."
require_rel "io"
require_rel "filter"
require_rel "source"
require_rel "mapping"
require_rel "validation"

module Oceanography

  class Parser

    attr_reader :netcdf_reader, :log, :log_helper, :config, :doc_file_writer,
                :schema_validator, :sanity_validator, :docs_db_publisher,
                :doc_splitter, :key_filter, :id_generator, :source_tracker


    def initialize(config = {})
      @config = Hashie::Mash.new({
        mappers: [MissingValuesMapper, KeyValueCorrectionsMapper, CommentsMapper,
                  ODSInstrumentTypeMapper, ODSCollectionMapper, ODSMooringMapper,
                  ODSClimateForecastMapper]
      }).deep_merge(config)

      @log = @config.log
      @log_helper = LogHelper.new(@config)
      @netcdf_reader = NetCDFReader.new({log: @log})
      @schema_validator = SchemaValidator.new({log: @log, schema: @config.schema})
      @sanity_validator = SanityValidator.new
      @doc_file_writer = DocFileWriter.new(@config)
      @docs_db_publisher = DocsDBPublisher.new({log: @log, url: @config.api_url})
      @doc_splitter = DocSplitter.new({log: @log})
      @key_filter = KeyFilter.new
      @id_generator = IdGenerator.new
    end

    def parse_files(files)
      rejected = []
      files.each_with_index do |file, index|
        begin
          current_file = file
          next if bad_data?(file)
          log_helper.start_parse(file, index, files.size)
          raw_hash = open_file(file)
          @source_tracker = SourceTracker.new(Hashie::Mash.new({
            log: log, api_url: config.api_url, file: file}))

          docs = doc_splitter.to_docs(raw_hash, process())

          source_tracker.track_source(docs)
          save_docs(docs, file)

          log_helper.stop_parse(file)
        rescue => e
          rejected.push({file: current_file, error: e})
          log_helper.abort(current_file, e)
        end
      end
      rejected
    end

    def process()
      lambda do |raw_doc, nc_hash|
        doc = raw_doc
        # Generate a namespaced uuid based on the json string and use that as the ID
        #doc["id"] = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, JSON.dump(doc)).to_s
        doc["id"] = id_generator.generate_id()
        doc["links"] = [{
          "href" => @source_tracker.source_doc_url,
          "rel" => "source", "title" => nc_hash["metadata"]["filename"]
        }]

        @config.mappers.each do |mapper|
          doc = Oceanography.const_get(mapper.to_s).new.map(doc)
        end
        doc = key_filter.filter(doc)

        log.debug(doc)
        errors = schema_validator.validate(doc)
        if !errors.empty?
          throw "#{doc["id"]} not valid! Errors: #{errors.to_json}"
        end
        doc
      end
    end

    def save_docs(docs, file)
      if write_files?
        doc_file_writer.write(docs, file)
      end

      if post_docs?
        docs_db_publisher.post(docs)
      end
    end

    def bad_data?(file)
      file =~ /#{File::SEPARATOR}OLD#{File::SEPARATOR}/ui
    end

    def open_file(file)
      begin
        netcdf_reader.open(file).hash()
      rescue => e
        log.warn("Could not open #{file}")
        raise e
      end
    end

    def write_files?
      config.out_path?
    end

    def post_docs?
      config.api_url?
    end

  end
end
