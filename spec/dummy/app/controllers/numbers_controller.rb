class NumbersController < ApplicationController
  after_filter only: [:index] { paginate(:numbers) }

  def index
    @numbers = Kaminari.paginate_array((1..params[:count].to_i).to_a).page(params[:page])
    render json: @numbers
  end
end
