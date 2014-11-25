require "logger"
require "hashie/mash"
require "fileutils"
require "uuidtools"
require "json"
require_relative "./log_helper"
require_relative "./netcdf_reader"
require_relative "./doc_splitter"
require_relative "./doc_filewriter"
require_relative "./docs_db_publisher"
require_relative "./filter/key_filter"
require "require_all"
require_rel "mapping"
require_rel "validation"

module Oceanography

  class NcToDocs

    attr_reader :netcdf_reader, :log, :log_helper, :config, :doc_file_writer,
                :schema_validator, :sanity_validator, :docs_db_publisher,
                :doc_splitter, :key_filter


    def initialize(config = {})
      @config = Hashie::Mash.new({
        log_level: Logger::INFO,
        file_pattern: ".",
        mappers: [MissingValuesMapper, KeyValueCorrectionsMapper, CommentsMapper,
                  ODSInstrumentTypeMapper, ODSCollectionMapper, ODSMooringMapper,
                  ODSClimateForecastMapper]
      }.merge(config) {|k, default, new| new || default })

      @log = Logger.new(STDERR)
      @log.level = @config.log_level
      @log_helper = LogHelper.new(@config.merge({log: @log}))
      @netcdf_reader = NetCDFReader.new({log: @log})
      @schema_validator = SchemaValidator.new({log: @log, schema: @config.schema})
      @sanity_validator = SanityValidator.new()
      @doc_file_writer = DocFileWriter.new(@config.merge({log: @log}))
      @docs_db_publisher = DocsDBPublisher.new({log: @log, url: @config.api_url})
      @doc_splitter = DocSplitter.new
      @key_filter = KeyFilter.new
    end

    def parse_files()
      log.info(log_helper.start_scan())
      files = Dir["#{config.file_pattern}"]
      status = true
      files.each_with_index do |file, index|
        next if bad_data?(file)
        log.info(log_helper.start_parse(file, index, files.size))

        begin
          raw_hash = open_file(file)
        rescue
          next
        end
        docs = process(raw_hash)
        valid_docs = docs.select { |doc| schema_validator.valid?(doc) }
        log.info("#{docs.size-valid_docs.size} of #{docs.size} docs rejected.")

        all_docs_valid = (valid_docs.size == docs.size)

        if config.out_path?
          status = doc_file_writer.write(valid_docs, file)
        end

        if config.api_url? && all_docs_valid
          status = docs_db_publisher.post(valid_docs, file)
        end

        log.info(log_helper.stop_parse(file))
        break if !status
      end
      log.info(log_helper.stop_scan(files, status))
    end

    def process(nc_hash)
      docs = doc_splitter.to_docs(nc_hash).map do |doc|
        processed_doc = doc
        @config.mappers.each do |mapper|
          processed_doc = Oceanography.const_get(mapper.to_s).new.map(processed_doc)
        end
        processed_doc = key_filter.filter(processed_doc)
        # Generate a namespaced uuid based on the json string and use that as the ID
        processed_doc["id"] = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, JSON.dump(processed_doc)).to_s
        processed_doc
      end
      docs
    end

    def bad_data?(file)
      file =~ /#{File::SEPARATOR}OLD#{File::SEPARATOR}/ui
    end

    def open_file(file)
      begin
        netcdf_reader.open(file).hash()
      rescue => e
        log.warn("Could not open #{file}")
        log.warn(e)
        raise e
      end
    end
  end
end
