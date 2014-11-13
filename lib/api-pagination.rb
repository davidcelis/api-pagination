require 'api-pagination/version'

module ApiPagination
  class << self
    attr_reader :paginator

    def paginate(collection, options = {})
      options[:page]     = options[:page].to_i
      options[:page]     = 1 if options[:page] <= 0
      options[:per_page] = options[:per_page].to_i

      case ApiPagination.paginator
      when :kaminari
        max_per_page = (options[:max_per_page] || Kaminari.config.max_per_page).to_i
        if options[:max_per_page] && options[:per_page] > max_per_page
          options[:per_page] = max_per_page
        elsif options[:per_page] <= 0
          options[:per_page] = Kaminari.config.default_per_page
        end
        collection = Kaminari.paginate_array(collection) if collection.is_a?(Array)
        collection.page(options[:page]).per(options[:per_page])
      when :will_paginate
        max_per_page = options[:max_per_page].to_i
        if options[:max_per_page] && options[:per_page] > max_per_page
          options[:per_page] = max_per_page
        elsif options[:per_page] <= 0
          options[:per_page] = WillPaginate.per_page
        end

        if defined?(Sequel::Dataset) && collection.kind_of?(Sequel::Dataset)
          collection.paginate(options[:page], options[:per_page])
        else
          collection.paginate(:page => options[:page], :per_page => options[:per_page])
        end
      else
        raise StandardError, "Unknown paginator: #{ApiPagination.paginator}"
      end
    end

    def pages_from(collection)
      {}.tap do |pages|
        unless collection.first_page?
          pages[:first] = 1
          pages[:prev]  = collection.current_page - 1
        end

        unless collection.last_page?
          pages[:last] = collection.total_pages
          pages[:next] = collection.current_page + 1
        end
      end
    end

    def total_from(collection)
      case ApiPagination.paginator
        when :kaminari      then collection.total_count.to_s
        when :will_paginate then collection.total_entries.to_s
      end
    end
  end
end

require 'api-pagination/hooks'
