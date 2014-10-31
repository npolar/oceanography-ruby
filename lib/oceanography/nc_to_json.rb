require "logger"
require "oceanography/netcdf"
require "oceanography/doc_splitter"
require "require_all"
require_rel "mapping"
require_rel "validation"

module Oceanography

  attr_reader :netcdf_reader, :log,
    :key_value_mapper, :cf_mapper, :schema_validator, :sanity_validator

  class NcToJson
    def initialize()
      @log = Logger.new(STDERR)
      @netcdf_reader = Oceanography::NetCDF.new({log: @log})
      @schema_validator = Oceanography::SchemaValidator.new()
      @sanity_validator = Oceanography::SanityValidator.new()
    end

    def get(file)
      netcdf_reader.open(file).dump()
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
      docs.to_json
    end
  end
end
