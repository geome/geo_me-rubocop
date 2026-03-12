require_relative "lib/rubocop/geo_me/version"

Gem::Specification.new do |spec|
  spec.name    = "geo_me-rubocop"
  spec.version = RuboCop::GeoMe::VERSION
  spec.authors = ["Geo.me"]
  spec.email   = ["engineering@geo.me"]

  spec.summary     = "Shared RuboCop config and custom cops for Geo.me"
  spec.description = "Shared RuboCop configuration and custom enforcement cops for all Geo.me Ruby projects."
  spec.homepage    = "https://github.com/geome/geo_me-rubocop"

  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir[
    "config/**/*",
    "lib/**/*",
    ".rubocop.yml",
    "geo_me-rubocop.gemspec"
  ]

  spec.metadata["default_lint_roller_plugin"] = "RuboCop::GeoMe::Plugin"

  spec.add_dependency "rubocop",     ">= 1.72"
  spec.add_dependency "lint_roller", "~> 1.1"
end
