require 'api-pagination/configuration'
require 'api-pagination/version'

module ApiPagination
  class << self
    def paginate(collection, options = {})
      options[:page]     = options[:page].to_i
      options[:page]     = 1 if options[:page] <= 0
      options[:per_page] = options[:per_page].to_i

      case ApiPagination.config.paginator
      when :kaminari
        paginate_with_kaminari(collection, options, options[:paginate_array_options] || {})
      when :will_paginate
        paginate_with_will_paginate(collection, options)
      else
        raise StandardError, "Unknown paginator: #{ApiPagination.config.paginator}"
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
      case ApiPagination.config.paginator
        when :kaminari      then collection.total_count.to_s
        when :will_paginate then collection.total_entries.to_s
      end
    end

    private

    def paginate_with_kaminari(collection, options, paginate_array_options = {})
      if Kaminari.config.max_per_page && options[:per_page] > Kaminari.config.max_per_page
        options[:per_page] = Kaminari.config.max_per_page
      elsif options[:per_page] <= 0
        options[:per_page] = Kaminari.config.default_per_page
      end

      collection = Kaminari.paginate_array(collection, paginate_array_options) if collection.is_a?(Array)
      collection.page(options[:page]).per(options[:per_page])
    end

    def paginate_with_will_paginate(collection, options)
      options[:per_page] = WillPaginate.per_page if options[:per_page] <= 0

      if defined?(Sequel::Dataset) && collection.kind_of?(Sequel::Dataset)
        collection.paginate(options[:page], options[:per_page])
      else
        collection.paginate(:page => options[:page], :per_page => options[:per_page])
      end
    end
  end
end

require 'api-pagination/hooks'
