module ApiPagination
  class Hooks
    def self.init!
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

      # Make sure kaminari or will paginate are defined
      begin
        require 'kaminari'
      rescue LoadError
      end

      begin
        require 'will_paginate'
      rescue LoadError
      end

      if _no_paginator_found?
        STDERR.puts <<-EOC
  Warning: api-pagination relies on either Kaminari or WillPaginate. Please
  install either dependency by adding one of the following to your Gemfile:

  gem 'kaminari'
  gem 'will_paginate'

  EOC
      end

      case ApiPagination.paginator
      when :will_paginate
        initialize_will_paginate! and return
      when :kaminari
        initialize_kaminari! and return
      when nil
        if _cannot_infer_paginator?
          STDERR.puts <<-EOC
  Warning: api-pagination relies on either Kaminari or WillPaginate, but these
  gems conflict. Please set ApiPagination.paginator in an initializer.

  EOC
          return
        end
      end

    end

    def self.initialize_kaminari!
      require 'kaminari/models/array_extension'
      ApiPagination.instance_variable_set(:@paginator, :kaminari)
    end

    def self.initialize_will_paginate!
      WillPaginate::CollectionMethods.module_eval do
        def first_page?() !previous_page end
        def last_page?() !next_page end
      end

      ApiPagination.instance_variable_set(:@paginator, :will_paginate)
    end

    def self._cannot_infer_paginator?
      defined?(Kaminari) &&
        defined?(WillPaginate::CollectionMethods) && ApiPagination.paginator.nil?
    end

    def self._no_paginator_found?
      !defined?(Kaminari) && !defined?(WillPaginate::CollectionMethods)
    end
  end
end
