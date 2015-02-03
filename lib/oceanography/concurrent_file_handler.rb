require_relative "log_helper"
require_relative "parser"
require "logger"
require "fileutils"
require "hashie/mash"

module Oceanography
  class ConcurrentFileHandler

    attr_reader :log_helper, :log, :config, :nr_of_threads

    def initialize(config = {})
      @config = Hashie::Mash.new({
        log_level: Logger::INFO,
        file_path: "."
      }).deep_merge(config)
      @nr_of_threads = @config.nr_of_threads || 4
      @log = Logger.new(STDERR)
      @log.level = @config.log_level
      original_formatter = Logger::Formatter.new
      @log.formatter = proc { |severity, datetime, progname, msg|
        original_formatter.call(severity, datetime, "#{progname} T#{Thread.current[:id]}", msg)
      }
      @config.merge!({log: @log})
      @log_helper = LogHelper.new(@config)
      Thread.current[:id] = 0
    end

    def parse_files()
      log_helper.start_scan()
      all_files = get_files()
      all_rejected = []
      threads = []
      divide_files(all_files).each_with_index do |files, index|
        thread = Thread.new do
          parser = Parser.new(@config)
          parser.parse_files(files)
        end
        thread[:id] = index+1
        threads.push(thread)
      end
      threads.each { |thread| all_rejected += thread.value }
      filename = "ncdocs_rejected_#{Time.now.strftime("%Y%m%dT%H%M%S")}.json"
      write_file_summary(filename, all_rejected)
      log_helper.stop_scan(all_files, all_rejected, filename)
    end

    def write_file_summary(filename, all_rejected)
      data = {
        config: config,
        rejected: all_rejected
      }
      File.open(File.join(Dir.pwd, filename), "w") {|f| f.write(JSON.pretty_generate(data)) }
    end

    def get_files()
      fp = config.file_path
      files = []
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

    def divide_files(files)
      batch_size = [(files.length / nr_of_threads).ceil,1].max
      start_index = 0
      Array.new([nr_of_threads, files.length].min) {
        batch = files.slice(start_index, batch_size)
        start_index += batch_size
        batch
      }
    end
  end
end
