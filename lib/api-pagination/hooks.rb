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
