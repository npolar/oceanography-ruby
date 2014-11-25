module Oceanography
  class LogHelper

    attr_reader :config, :timing

    def initialize(config)
      @config = config
      @timing = {}
    end

    def start_scan()
      message = "Parsing nc files in #{config.file_pattern}"
      message << " writing to #{config.out_path}" if config.out_path?
      message << " publishing to #{config.api_url}" if config.api_url?
      message
    end

    def stop_scan(files, status)
      if status
        "Parsing of #{files.size || 0} files done."
      else
        "Parsing aborted due to failure"
      end
    end

    def start_parse(file, index, total)
      timing[file] = Time.now
      "Processing file #{index+1}/#{total} @ #{file}"
    end

    def stop_parse(file)
      time = Time.now - timing[file]
      "Processing #{file} took #{time}ms"
    end
  end
end
