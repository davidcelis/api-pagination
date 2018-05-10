require 'action_controller'
require 'api-pagination/hooks'

Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  resources :tweets, :only => [:index] do
    collection do
      get :index_with_scope
      get :index_with_custom_render
      get :index_with_no_per_page
      get :index_with_paginate_array_options
    end
  end
end

class TweetsSerializer
  def initialize(tweets)
    @tweets = tweets
  end

  def to_json(options = {})
    { tweets: @tweets.map { |t| { number: t.n } } }.to_json
  end
end

class TweetsController < ApiPagination::Hooks.rails_parent_controller
  include Rails.application.routes.url_helpers

  def index
    total = params.fetch(:count).to_i

    if params[:with_headers]
      query = request.query_parameters.dup
      query.delete(:with_headers)
      headers['Link'] = %(<#{tweets_url}?#{query.to_param}>; rel="without")
    end
    create_tweets(total)

    cursor_paginate json: Tweet.all, per_page: 10
  end

  def index_with_scope
    total = params.fetch(:count).to_i

    create_tweets(total)

    cursor_paginate json: Tweet.where('n%2 = 1'), per_page: 10
  end

  def index_with_custom_render
    total  = params.fetch(:count).to_i
    create_tweets(total)
    tweets = Tweet.all
    tweets = cursor_paginate tweets, per_page: 10

    render json: TweetsSerializer.new(tweets)
  end

  def index_with_no_per_page
    total  = params.fetch(:count).to_i
    create_tweets(total)
    tweets = Tweet.all
    tweets = cursor_paginate tweets

    render json: TweetsSerializer.new(tweets)
  end

  private

  def create_tweets(count)
    count.times do |n|
      Tweet.create!(n: n + 1)
    end
  end
end
