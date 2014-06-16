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
  resources :numbers, :only => [:index]
end

class NumbersController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    page = params.fetch(:page, 1).to_i
    total = params.fetch(:count).to_i

    if params[:with_headers]
      query = request.query_parameters.dup
      query.delete(:with_headers)
      headers['Link'] = %(<#{numbers_url}?#{query.to_param}>; rel="without")
    end

    paginate :json => (1..total).to_a, :per_page => 10
  end
end

class NumbersResponderController < ActionController::Base
  include Rails.application.routes.url_helpers

  respond_to :json

  def index
    page = params.fetch(:page, 1).to_i
    total = params.fetch(:count).to_i

    if params[:with_headers]
      query = request.query_parameters.dup
      query.delete(:with_headers)
      headers['Link'] = %(<#{numbers_url(:format => params[:format])}?#{query.to_param}>; rel="without")
    end

    paginate_with (1..total).to_a, :per_page => 10
  end
end

class NumbersManipulatedController < ActionController::Base
  include Rails.application.routes.url_helpers

  respond_to :json

  def index
    page = params.fetch(:page, 1).to_i
    total = params.fetch(:count).to_i
    paginate_with (1..total).to_a, :per_page => 10 do |collection|
      manipulate(collection)
    end
  end

  protected

  def manipulate(collection)
    collection.map{|obj| obj.to_s * 3}
  end
end
