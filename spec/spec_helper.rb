require 'api-pagination'
require 'rspec/autorun'
require 'ostruct'

# Quacks like Kaminari
PaginatedSet = Struct.new(:current_page, :total_count) do
  def limit_value() 25 end

  def total_pages
    total_count.zero? ? 1 : (total_count.to_f / limit_value).ceil
  end

  def first_page?() current_page == 1 end
  def last_page?() current_page == total_pages end
end

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
