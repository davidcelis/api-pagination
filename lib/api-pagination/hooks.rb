begin; require 'rails'; rescue LoadError; end
begin; require 'rails-api'; rescue LoadError; end

if defined?(Rails)
  module ApiPagination
    module Hooks
      def self.rails_parent_controller
        if Gem::Version.new(Rails.version) >= Gem::Version.new('5') || defined?(ActionController::API)
          ActionController::API
        else
          ActionController::Base
        end
      end
    end
  end

  require 'rails/pagination'

  ActiveSupport.on_load(:action_controller) do
    ApiPagination::Hooks.rails_parent_controller.send(:include, Rails::Pagination)
  end
end

begin; require 'grape'; rescue LoadError; end
if defined?(Grape::API)
  require 'grape/pagination'
  Grape::API.send(:include, Grape::Pagination)
end

begin; require 'kaminari';      rescue LoadError; end
begin; require 'will_paginate'; rescue LoadError; end

unless defined?(Kaminari) || defined?(WillPaginate::CollectionMethods)
  Kernel.warn <<-WARNING.gsub(/^\s{4}/, '')
    Warning: api-pagination relies on either Kaminari or WillPaginate. Please
    install either dependency by adding one of the following to your Gemfile:

    gem 'kaminari'
    gem 'will_paginate'
  WARNING
end

