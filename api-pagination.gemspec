$:.unshift(File.expand_path("../lib", __FILE__))
require "api-pagination/version"

Gem::Specification.new do |s|
  s.name = "api-pagination"
  s.version = ApiPagination::VERSION
  s.authors = ["David Celis"]
  s.email = ["me@davidcel.is"]
  s.description = "Link header pagination for Rails and Grape APIs"
  s.summary = "Link header pagination for Rails and Grape APIs. Don't use the request body."
  s.homepage = "https://github.com/davidcelis/api-pagination"
  s.license = "MIT"

  s.files = Dir["lib/**/*"]
  s.require_paths = ["lib"]

  s.required_ruby_version = "> 2.7"

  s.add_development_dependency "kaminari", "~> 1.2", ">= 1.2.1"
  s.add_development_dependency "pagy", "~> 43.3"
  s.add_development_dependency "will_paginate", "~> 3.3", ">= 3.3.1"

  s.add_development_dependency "rspec", "~> 3.10"
  s.add_development_dependency "grape", "~> 1.6"
  s.add_development_dependency "railties", "~> 7.0"
  s.add_development_dependency "actionpack", "~> 7.0"
  s.add_development_dependency "sequel", "~> 5.49"
  s.add_development_dependency "activerecord-nulldb-adapter", "~> 0.9.0"
end
