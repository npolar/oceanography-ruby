# http://betterspecs.org/
require "simplecov"
require "bundler/setup"
require "rspec"

SimpleCov.start do
  add_filter do |src|
    src.lines.count < 5
  end
  add_filter "/spec/"
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
