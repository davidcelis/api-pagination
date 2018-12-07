begin; require 'grape'; rescue LoadError; end
if defined?(Grape::API)
  require 'grape/pagination'

  klass = if Grape::VERSION >= '1.2.0' || defined?(Grape::API::Instance)
    Grape::API::Instance
  else
    Grape::API
  end

  klass.send(:include, Grape::Pagination)
end

begin; require 'pagy';          rescue LoadError; end
begin; require 'kaminari';      rescue LoadError; end
begin; require 'will_paginate'; rescue LoadError; end

unless defined?(Pagy) || defined?(Kaminari) || defined?(WillPaginate::CollectionMethods)
  Kernel.warn <<-WARNING.gsub(/^\s{4}/, '')
    Warning: api-pagination relies on either Pagy, Kaminari, or WillPaginate.
    Please install a paginator by adding one of the following to your Gemfile:

    gem 'pagy'
    gem 'kaminari'
    gem 'will_paginate'
  WARNING
end

if defined?(Rails)
  module ApiPagination
    module Hooks
      def self.rails_parent_controller
        if Rails::VERSION::MAJOR >= 5 || defined?(ActionController::API)
          ActionController::API
        else
          ActionController::Base
        end
      end
    end
  end

  require 'api-pagination/railtie'
end
