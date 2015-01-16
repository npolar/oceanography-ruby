module Oceanography
  class LogHelper

    attr_reader :config, :timing, :log

    def initialize(config)
      @config = config
      @log = config.log
      @timing = {}
    end

    def start_scan()
      timing[:main] = Time.now
      message = "Parsing nc files in #{config.file_pattern}"
      message << " writing to #{config.out_path}" if config.out_path?
      message << " publishing to #{config.api_url}" if config.api_url?
      log.info message
    end

    def stop_scan(files, rejected)
      time = (Time.now - timing[:main])
      log.info "Parsing of #{files.size || 0} files done in #{time}s. Rejections: #{rejected.to_json}"
    end

    def start_parse(file, index, total)
      timing[file] = Time.now
      log.info "Processing file #{index+1}/#{total} @ #{file}"
    end

    def stop_parse(file)
      time = (Time.now - timing[file]) * 1000
      log.info "Processing #{file} took #{time}ms"
    end

    def abort(file, e)
      log.warn "Parsing of #{file} aborted due to #{e}"
      puts e.backtrace
    end
  end
end
