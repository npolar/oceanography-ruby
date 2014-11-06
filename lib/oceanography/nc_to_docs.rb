require "logger"
require "hashie/mash"
require_relative "./netcdf"
require_relative "./doc_splitter"
require "require_all"
require_rel "mapping"
require_rel "validation"

module Oceanography

  attr_reader :netcdf_reader, :log, :config

  class NcToDocs
    def initialize(config = {})
      @config = Hashie::Mash.new({
        out_path: File.join(File.expand_path("~"), "json"),
        log_level: Logger::INFO
      }.merge(config) {|k, default, new| new || default })

      @log = Logger.new(STDERR)
      @log.level = config.log_level
      @netcdf_reader = Oceanography::NetCDF.new({log: log})
      @schema_validator = Oceanography::SchemaValidator.new({log: log, schema: config.schema})
      @sanity_validator = Oceanography::SanityValidator.new()
    end

    def parse_files()
      log.info("Parsing nc files in #{config.base_path} to #{config.out_path}")
      Dir["#{config.base_path}/**/*.nc"].each do |file|
        log.info("Processing #{file}")
        t1 = Time.now
        raw_hash = get(file)
        json_path = File.join(config.out_path, file[/(.+#{File::SEPARATOR}).+.nc$/ui, 1])
        docs = process(raw_hash)
        valid_docs = docs.select { |doc| schema_validator.valid?(doc) }
        log.info("#{docs.size-valid_docs.size} of #{docs.size} docs rejected.")
        valid_docs.each {|doc| writeToFile(doc, json_path)}
        log.info("Wrote #{valid_docs.size} docs to #{json_path} in #{Time.now - t1}ms")
      end
    end

    def get(file)
      @netcdf_reader.open(file).hash()
    end

    def process(nc_hash)
      docs = DocSplitter.to_docs(nc_hash).map do |doc|
        processed_doc = doc
        [MissingValuesMapper, KeyValueMapper, CommentsMapper,
          CollectionMapper, ClimateForecastMapper].each do |mapper|
          processed_doc = mapper.map(processed_doc)
        end
        processed_doc
      end
      docs
    end

    def writeToFile(doc, path)
      require "fileutils"

      file = File.join(path, doc["id"]+".json")
      log.debug("Writing #{file}")
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end
      File.open(File.join(path, doc["id"]+".json"), "w") {|f| f.write(JSON.pretty_generate(doc)) }
    end

    def putToAPI(doc, url)
    end
  end
end
