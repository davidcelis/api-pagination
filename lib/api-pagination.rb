require 'api-pagination/version'

module ApiPagination
  class << self
    attr_reader :paginator

    def paginate(collection, options = {})
      options[:page]     ||= 1

      case ApiPagination.paginator
      when :kaminari
        options[:per_page] = (options[:per_page].to_i <= 0 ? Kaminari.config.default_per_page : options[:per_page])
        options[:per_page] = (options[:per_page].to_i > Kaminari.config.max_per_page ? Kaminari.config.max_per_page : options[:per_page]) if Kaminari.config.max_per_page
        collection = Kaminari.paginate_array(collection) if collection.is_a?(Array)
        collection.page(options[:page]).per(options[:per_page])
      when :will_paginate
        options[:per_page] = (options[:per_page].to_i <= 0 ? WillPaginate.per_page : options[:per_page])
        if defined?(Sequel::Dataset) && collection.kind_of?(Sequel::Dataset)
          collection.paginate(options[:page], options[:per_page])
        else
          collection.paginate(:page => options[:page], :per_page => options[:per_page])
        end
      else
        fail StandardError, "Unknown paginator: #{ApiPagination.paginator}"
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
