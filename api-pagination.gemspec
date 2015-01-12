# encoding: utf-8
$:.unshift(File.expand_path('../lib', __FILE__))
require 'api-pagination/version'

Gem::Specification.new do |s|
  s.name          = 'api-pagination'
  s.version       = ApiPagination::VERSION
  s.authors       = ['David Celis']
  s.email         = ['me@davidcel.is']
  s.description   = 'Link header pagination for Rails and Grape APIs'
  s.summary       = "Link header pagination for Rails and Grape APIs. Don't use the request body."
  s.homepage      = 'https://github.com/davidcelis/api-pagination'
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*']
  s.test_files    = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'grape', '>= 0.10.0'
  s.add_development_dependency 'railties', '>= 3.0.0'
  s.add_development_dependency 'actionpack', '>= 3.0.0'
  s.add_development_dependency 'sequel', '>= 4.9.0'
end
