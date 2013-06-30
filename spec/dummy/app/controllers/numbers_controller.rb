class NumbersController < ApplicationController
  after_filter only: [:index] { paginate(:numbers) }

  # quacks like Kaminari
  PaginatedSet = Struct.new(:current_page, :total_count) do
    def limit_value() 25 end

    def total_pages
      total_count.zero? ? 1 : (total_count.to_f / limit_value).ceil
    end

    def first_page?() current_page == 1 end
    def last_page?() current_page == total_pages end
  end

  def index
    @numbers = PaginatedSet.new(params.fetch(:page, 1).to_i, params.fetch(:count).to_i)
    render json: @numbers
  end
end
