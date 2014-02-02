require 'api-pagination/hooks'
require 'api-pagination/version'

module ApiPagination
  class << self
    attr_reader :paginator

    def paginate(collection, options = {}, &block)
      options[:page]     ||= 1
      options[:per_page] ||= 10

      case ApiPagination.paginator
      when :kaminari
        collection.page(options[:page]).per(options[:per_page]).tap(&block)
      when :will_paginate
        collection.paginate(:page => options[:page], :per_page => options[:per_page]).tap(&block)
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
        when :kaminari      then collection.total_count
        when :will_paginate then collection.total_entries
      end
    end
  end
end

ApiPagination::Hooks.init
