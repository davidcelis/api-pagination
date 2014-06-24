require 'api-pagination/hooks'
require 'api-pagination/version'

module ApiPagination
  class << self
    attr_reader :paginator

    def paginate(collection, options = {})
      options[:page]     ||= 1
      options[:per_page] = (options[:per_page].to_i <= 0 ? 25 : options[:per_page])

      case ApiPagination.paginator
      when :kaminari
        collection = Kaminari.paginate_array(collection) if collection.is_a?(Array)
        collection.page(options[:page]).per(options[:per_page])
      when :will_paginate
        if defined?(Sequel::Dataset) && collection.kind_of?(Sequel::Dataset)
          collection.paginate(options[:page], options[:per_page])
        else
          collection.paginate(:page => options[:page], :per_page => options[:per_page])
        end
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
