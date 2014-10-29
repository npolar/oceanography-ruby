require "logger"
require "oceanography/netcdf"
require "oceanography/mapping/climate_forecast_mapper"
require "oceanography/mapping/key_mapper"
require "oceanography/mapping/value_mapper"
require "oceanography/validation/sanity_validator"
require "oceanography/validation/schema_validator"

module Oceanography

  attr_reader :netcdf_reader, :log, :value_mapper,
    :key_mapper, :cf_mapper, :schema_validator, :sanity_validator

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
      nc_hash.map(&ClimateForecast)
      nc_hash.map(&KeyMapper)
      nc_hash.map(&ValueMapper)
      sanity_validator.validate(nc_hash)
      schema_validator.validate(nc_hash)
      nc_hash
    end
  end
end
