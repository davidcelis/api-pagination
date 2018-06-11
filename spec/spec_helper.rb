require 'support/numbers_controller'
require 'support/numbers_api'
require 'api-pagination'

if ENV['PAGINATOR'].nil?
  warn <<-WARNING
No PAGINATOR set. Defaulting to pagy.

To test against kaminari, run `PAGINATOR=kaminari bundle exec rspec`
To test against will_paginate, run `PAGINATOR=will_paginate bundle exec rspec`
WARNING

  ENV['PAGINATOR'] = 'pagy'
end

require ENV['PAGINATOR']
ApiPagination.config.paginator = ENV['PAGINATOR'].to_sym

require 'will_paginate/array' if ENV['PAGINATOR'].to_sym == :will_paginate

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include ControllerExampleGroup, :type => :controller

  # Disable the 'should' syntax.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  def app
    NumbersAPI
  end
end
