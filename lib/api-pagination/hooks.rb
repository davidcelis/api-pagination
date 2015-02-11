begin; require 'rails'; rescue LoadError; end
if defined?(ActionController::Base)
  require 'rails/pagination'
  ActionController::Base.send(:include, Rails::Pagination)
end

begin; require 'rails-api'; rescue LoadError; end
if defined?(ActionController::API)
  require 'rails/pagination'
  ActionController::API.send(:include, Rails::Pagination)
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
