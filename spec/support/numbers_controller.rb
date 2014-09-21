require 'action_controller'
require 'ostruct'

module Rails
  def self.application
    @application ||= begin
      routes = ActionDispatch::Routing::RouteSet.new
      OpenStruct.new(:routes => routes, :env_config => {})
    end
  end
end

module ControllerExampleGroup
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, ActionController::TestCase::Behavior)

    base.prepend_before do
      @routes = Rails.application.routes
      @controller = described_class.new
    end
  end

  module ClassMethods
    def setup(*methods)
      methods.each do |method|
        if method.to_s =~ /^setup_(fixtures|controller_request_and_response)$/
          prepend_before { send method }
        else
          before         { send method }
        end
      end
    end

    def teardown(*methods)
      methods.each { |method| after { send method } }
    end
  end
end

Rails.application.routes.draw do
  resources :numbers, :only => [:index] do
    get :index_with_custom_render, on: :collection
  end
end

class NumbersSerializer
  def initialize(numbers)
    @numbers = numbers
  end

  def to_json(options = {})
    { numbers: @numbers.map { |n| { number: n } } }.to_json
  end
end

class NumbersController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    total = params.fetch(:count).to_i

    if params[:with_headers]
      query = request.query_parameters.dup
      query.delete(:with_headers)
      headers['Link'] = %(<#{numbers_url}?#{query.to_param}>; rel="without")
    end

    paginate :json => (1..total).to_a, :per_page => 10
  end

  def index_with_custom_render
    total   = params.fetch(:count).to_i
    numbers = (1..total).to_a
    numbers = paginate numbers, :per_page => 10

    render json: NumbersSerializer.new(numbers)
  end
end
