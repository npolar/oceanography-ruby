#!/usr/bin/env ruby
require "bundler/setup"
require "optparse"
require_relative "../lib/oceanography/nc_to_docs"

begin
  options = {}
  banner = "Usage: ./ncdocs.sh [options] PATH"
  optparse = OptionParser.new do |opts|
    opts.banner = banner

    opts.on('-o', '--outpath PATH', 'Path to write json docs to. Default ~/json') { |v| options[:out_path] = v }
    opts.on('-s', '--schema PATH', 'Path to json schema to validate docs against') { |v| options[:schema] = v }
    opts.on('-v', '--verbose', 'Log level debug. Default info') { |v| options[:log_level] = Logger::DEBUG }
    opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
    end

  end.parse!

  def args_ok?()
    ARGV.size > 0
  end

  if !args_ok?
    puts banner
    exit
  end

  options["base_path"] = ARGV[0]

  nc_to_docs = Oceanography::NcToDocs.new(options)
  nc_to_docs.parse_files()
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end
