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
require_relative "./id_generator"
require "require_all"
require_rel "mapping"
require_rel "validation"

module Oceanography

  class NcToDocs

    attr_reader :netcdf_reader, :log, :log_helper, :config, :doc_file_writer,
                :schema_validator, :sanity_validator, :docs_db_publisher,
                :doc_splitter, :key_filter, :id_generator


    def initialize(config = {})
      @config = Hashie::Mash.new({
        log_level: Logger::INFO,
        file_path: ".",
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
      @doc_splitter = DocSplitter.new({log: @log})
      @key_filter = KeyFilter.new
      @id_generator = IdGenerator.new
    end

    def parse_files()
      log.info(log_helper.start_scan())
      files = get_files()
      current_file = nil
      begin
        files.each_with_index do |file, index|
          current_file = file
          next if bad_data?(file)
          log.info(log_helper.start_parse(file, index, files.size))

          raw_hash = open_file(file)
          docs = doc_splitter.to_docs(raw_hash, process())

          save_docs(docs, file)

          log.info(log_helper.stop_parse(file))
        end
      rescue => e
        log.error(log_helper.abort(current_file))
        raise e
      end
      log.info(log_helper.stop_scan(files))
    end

    def process()
      lambda do |raw_doc|
        doc = raw_doc
        @config.mappers.each do |mapper|
          doc = Oceanography.const_get(mapper.to_s).new.map(doc)
        end
        doc = key_filter.filter(doc)
        # Generate a namespaced uuid based on the json string and use that as the ID
        #doc["id"] = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, JSON.dump(doc)).to_s
        doc["_id"] = id_generator.generateId()
        log.debug(doc)
        if !schema_validator.valid?(doc)
          throw "#{doc["_id"]} not valid!"
        end
        doc
      end
    end

    def save_docs(docs, file)
      if config.out_path?
        doc_file_writer.write(docs, file)
      end

      if config.api_url?
        docs_db_publisher.post(docs, file)
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

    def get_files()
      files = []
      fp = config.file_path
      if !fp.kind_of?(Array)
        fp = [fp]
      end
      fp.each do |f|
        if Dir.exist?(f)
          files += Dir["#{f}#{File::SEPARATOR}**#{File::SEPARATOR}*.nc"]
        elsif File.exist?(f)
          files.push(f)
        end
      end
      files
    end
  end
end
