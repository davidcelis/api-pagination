require 'rspec/core/rake_task'
require 'coveralls/rake/task'

RSpec::Core::RakeTask.new(:spec)
Coveralls::RakeTask.new

task default: [:spec, 'coveralls:push']
