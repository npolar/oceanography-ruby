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
      @sanity_validator = SanityValidator.new({log: @log})
      @doc_file_writer = DocFileWriter.new(@config)
      @docs_db_publisher = DocsDBPublisher.new({log: @log, url: @config.api_url})
      @doc_splitter = DocSplitter.new({log: @log, schema: @config.schema})
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
          nc_hash = open_file(file).freeze
          @source_tracker = SourceTracker.new(Hashie::Mash.new({
            log: log, api_url: config.api_url, file: file}))

          docs = doc_splitter.to_docs(nc_hash, process())

          source_tracker.track_source(docs)
          save_docs(docs, file)

          log_helper.stop_parse(file)
        rescue => e
          errors = e.respond_to?(:errors) ? e.errors : [e.message]
          rejected.push({file: current_file, errors: errors })
          log_helper.abort(current_file, e.message)
          log.debug(e.backtrace.join("\n"))
        end
      end
      rejected
    end

    def process()
      lambda do |doc, nc_hash|
        doc.merge!(source_data(nc_hash))

        @config.mappers.each do |mapper|
          doc = Oceanography.const_get(mapper.to_s).new.map(doc, nc_hash)
        end
        doc = key_filter.filter(doc)

        log.debug(doc)
        errors = validate(doc)
        if !errors.empty?
          puts "ERRORS: #{errors}"
          raise ParsingError.new(errors), "Validation failed"
        end
        doc
      end
    end

    def source_data(nc_hash)
      {
        "id" => id_generator.generate_id(),
        "links" => [{
          "href" => @source_tracker.source_doc_url,
          "rel" => "source",
          "title" => nc_hash["metadata"]["filename"]
        }]
      }
    end

    def validate(doc)
      schema_validator.validate(doc) +
      sanity_validator.validate(doc)
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
