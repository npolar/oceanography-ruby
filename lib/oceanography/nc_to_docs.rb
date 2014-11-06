require "logger"
require "hashie/mash"
require "fileutils"
require_relative "./log_helper"
require_relative "./netcdf_reader"
require_relative "./doc_splitter"
require_relative "./doc_filewriter"
require_relative "./docs_db_publisher"
require "require_all"
require_rel "mapping"
require_rel "validation"

module Oceanography

  attr_reader :netcdf_reader, :log, :log_helper, :config, :doc_file_writer,
              :schema_validator, :sanity_validator, :docs_db_publisher

  class NcToDocs
    def initialize(config = {})
      @config = Hashie::Mash.new({
        log_level: Logger::INFO,
        mappers: [MissingValuesMapper, KeyValueCorrectionsMapper, CommentsMapper,
          CollectionMapper, ClimateForecastMapper]
      }.merge(config) {|k, default, new| new || default })

      @log = Logger.new(STDERR)
      @log.level = @config.log_level
      @log_helper = LogHelper.new(@config.merge({log: @log}))
      @netcdf_reader = NetCDFReader.new({log: @log})
      @schema_validator = SchemaValidator.new({log: @log, schema: @config.schema})
      @sanity_validator = SanityValidator.new()
      @doc_file_writer = DocFileWriter.new({log: @log})
      @docs_db_publisher = DocsDBPublisher.new({log: @log, url: @config.api_url})
    end

    def parse_files()
      log.info(log_helper.start_scan())
      Dir["#{config.base_path}/**/*.nc"].each do |file|
        log.info(log_helper.start_parse(file))
        raw_hash = netcdf_reader.open(file).hash()
        docs = process(raw_hash)
        valid_docs = docs.select { |doc| schema_validator.valid?(doc) }
        log.info("#{docs.size-valid_docs.size} of #{docs.size} docs rejected.")

        all_docs_valid = (valid_docs.size == docs.size)

        if config.out_path?
          DocFileWriter.write(valid_docs, file)
        end

        if config.api_url? && all_docs_valid
          DocsDBPublisher.post(valid_docs, file)
        end

        log.info(log_helper.stop_parse())
      end
    end

    def process(nc_hash)
      docs = DocSplitter.to_docs(nc_hash).map do |doc|
        processed_doc = doc
        @config.mappers.each do |mapper|
          processed_doc = mapper.map(processed_doc)
        end
        processed_doc
      end
      docs
    end
  end
end
