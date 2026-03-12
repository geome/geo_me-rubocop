require "simplecov"
SimpleCov.start

require "rubocop"
require "geo_me-rubocop"
require "rubocop/rspec/support"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
