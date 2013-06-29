# encoding: utf-8
$:.unshift(File.expand_path('../lib', __FILE__))
require 'api-pagination/version'

Gem::Specification.new do |s|
  s.name          = 'api-pagination'
  s.version       = ApiPagination::VERSION
  s.authors       = ['David Celis']
  s.email         = ['me@davidcel.is']
  s.description   = 'Link header pagination for Rails APIs'
  s.summary       = "Link header pagination for Rails APIs. Don't use the request body."
  s.homepage      = 'https://github.com/davidcelis/api-pagination'
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*']
  s.test_files    = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'kaminari', '>= 0.13.0'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rspec-rails'
end
