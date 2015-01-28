require 'api-pagination/version'
require 'api-pagination/hooks'

module ApiPagination
  class << self
    attr_accessor :paginator
    attr_writer   :total_header, :per_page_header

    def config
      yield(self) if block_given?
      ApiPagination::Hooks.init!
    end

    def paginate(collection, options = {})
      options[:page]     = options[:page].to_i
      options[:page]     = 1 if options[:page] <= 0
      options[:per_page] = options[:per_page].to_i

      case ApiPagination.paginator
      when :kaminari
        if Kaminari.config.max_per_page && options[:per_page] > Kaminari.config.max_per_page
          options[:per_page] = Kaminari.config.max_per_page
        elsif options[:per_page] <= 0
          options[:per_page] = Kaminari.config.default_per_page
        end
        collection = Kaminari.paginate_array(collection) if collection.is_a?(Array)
        collection.page(options[:page]).per(options[:per_page])
      when :will_paginate
        options[:per_page] = WillPaginate.per_page if options[:per_page] <= 0

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

    def total_header
      @total_header ||= 'Total'
    end

    def per_page_header
      @per_page_header ||= 'Per-Page'
    end
  end
end
