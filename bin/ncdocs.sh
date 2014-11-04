#!/usr/bin/env ruby
require "bundler/setup"
require_relative "../lib/oceanography/nc_to_docs"

Oceanography::NcToDocs.parse(ARGV)
