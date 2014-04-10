module ApiPagination
  class Hooks
    def self.init
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

      begin; require 'will_paginate'; rescue LoadError; end
      if defined?(WillPaginate::CollectionMethods)
        WillPaginate::CollectionMethods.module_eval do
          def first_page?() !previous_page end
          def last_page?() !next_page end
        end

        ApiPagination.instance_variable_set(:@paginator, :will_paginate)
      end

      begin; require 'kaminari'; rescue LoadError; end
      if defined?(Kaminari)
        ApiPagination.instance_variable_set(:@paginator, :kaminari)
      end

      STDERR.puts <<-EOC unless defined?(Kaminari) || defined?(WillPaginate)
Warning: api-pagination relies on either Kaminari or WillPaginate. Please
install either dependency by adding one of the following to your Gemfile:

gem 'kaminari'
gem 'will_paginate'

EOC
    end
  end
end

ApiPagination::Hooks.init
