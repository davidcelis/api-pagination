require 'support/numbers_controller'
require 'support/numbers_api'
require 'api-pagination'
require 'pry'

if ENV['PAGINATOR'].nil?
  warn 'No PAGINATOR set. Defaulting to kaminari. To test against will_paginate, run `PAGINATOR=will_paginate bundle exec rspec`'
  ENV['PAGINATOR'] = 'kaminari'
end

def testing_cursor?
  ENV['PAGINATOR'] == 'cursor'
end

if testing_cursor?
  require 'sqlite3'
  require 'active_record'
  require 'database_cleaner'

  DatabaseCleaner[:active_record].strategy = :transaction if defined? ActiveRecord

  RSpec.configure do |config|
    config.before :suite do
      DatabaseCleaner.clean_with :truncation if defined? ActiveRecord
    end
    config.before :each do
      DatabaseCleaner.start
    end
    config.after :each do
      DatabaseCleaner.clean
    end
  end

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  ActiveRecord::Schema.define do
    self.verbose = false
    create_table :tweets, force: true do |t|
      t.integer :n
      t.string :text
    end
  end

  class Tweet < ActiveRecord::Base
  end
else
  require ENV['PAGINATOR']
end

ApiPagination.config.paginator = ENV['PAGINATOR'].to_sym

require 'will_paginate/array'

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

def response_values(attr)
  JSON.parse(response.body).map{|e| e[attr]}
end
