#!/usr/bin/env ruby
require "bundler/setup"
require_relative "../lib/oceanography/netcdf"

Oceanography::NetCDF.ncjson(ARGV)
