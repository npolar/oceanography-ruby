module Oceanography
  class LogHelper

    attr_reader :config, :timing

    def initialize(config)
      @config = config
      @timing = {}
    end

    def start_scan()
      message = "Parsing nc files in #{config.base_path}"
      message << " writing to #{config.out_path}" if config.out_path?
      message << " publishing to #{config.api_url}" if config.api_url?
      message
    end

    def start_parse(file)
      timing[file] = Time.now
      "Processing #{file}"
    end

    def stop_parse(file, valid_docs)
      time = Time.now - timing[file]
      "Processing #{file} took #{time}ms"
    end
  end
end
