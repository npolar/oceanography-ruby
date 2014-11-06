require "json-schema"
require "json"
require "hashie/mash"

module Oceanography
  class SchemaValidator

    attr_reader :schema, :log

    def initialize(options)
      options = Hashie::Mash.new(options)
      @log = options.log
      @schema = options.schema || {}
    end

    ## Raises exception if not valid
    def valid?(data)
      errors = JSON::Validator.fully_validate(schema, data)
      errors.each { |e| log.error("Validating #{data['id']} " + e) }
      errors.empty?
    end
  end
end
