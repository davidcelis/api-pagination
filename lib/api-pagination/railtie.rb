require 'rails/railtie'

module ApiPagination
  class Railtie < ::Rails::Railtie
    initializer :api_pagination do
      ActiveSupport.on_load(:action_controller) do
        require 'rails/pagination'

        klass = if Rails::VERSION::MAJOR >= 5 || defined?(ActionController::API)
          ActionController::API
        else
          ActionController::Base
        end

        klass.send(:include, Rails::Pagination)
      end
    end
  end
end
