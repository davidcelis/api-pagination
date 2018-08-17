require 'api-pagination/configuration'
require 'api-pagination/version'

module ApiPagination
  class << self
    def paginate(collection, options = {})
      options[:page]        = options[:page].to_i
      options[:page]        = 1 if options[:page] <= 0
      options[:per_page]    = options[:per_page].to_i
      options[:paginator] ||= ApiPagination.config.paginator

      case options[:paginator]
      when :pagy
        paginate_with_pagy(collection, options)
      when :kaminari
        paginate_with_kaminari(collection, options, options[:paginate_array_options] || {})
      when :will_paginate
        paginate_with_will_paginate(collection, options)
      else
        raise StandardError, "Unknown paginator: #{options[:paginator]}"
      end
    end

    def pages_from(collection, options = {})
      options[:paginator] ||= ApiPagination.config.paginator
      return pagy_pages_from(collection, options) if options[:paginator] == :pagy && collection.is_a?(Pagy)

      {}.tap do |pages|
        unless collection.first_page?
          pages[:first] = 1
          pages[:prev]  = collection.current_page - 1
        end

        unless collection.last_page? || (options[:paginator] == :kaminari && collection.out_of_range?)
          pages[:last] = collection.total_pages if options[:include_total]
          pages[:next] = collection.current_page + 1
        end
      end
    end

    def total_from(collection, options)
      options[:paginator] ||= ApiPagination.config.paginator
      case options[:paginator]
        when :pagy          then collection.count.to_s
        when :kaminari      then collection.total_count.to_s
        when :will_paginate then collection.total_entries.to_s
      end
    end

    private

    def paginate_with_pagy(collection, options)
      if Pagy::VARS[:max_per_page] && options[:per_page] > Pagy::VARS[:max_per_page]
        options[:per_page] = Pagy::VARS[:max_per_page]
      elsif options[:per_page] <= 0
        options[:per_page] = Pagy::VARS[:items]
      end

      pagy = pagy_from(collection, options)
      collection = if collection.respond_to?(:offset) && collection.respond_to?(:limit)
        collection.offset(pagy.offset).limit(pagy.items)
      else
        collection[pagy.offset, pagy.items]
      end

      return [collection, pagy]
    end

    def pagy_from(collection, options)
      if options[:count]
        count = options[:count]
      else
        count = collection.is_a?(Array) ? collection.count : collection.count(:all)
      end

      Pagy.new(count: count, items: options[:per_page], page: options[:page])
    end

    def pagy_pages_from(pagy, options)
      {}.tap do |pages|
        unless pagy.page == 1
          pages[:first] = 1
          pages[:prev]  = pagy.prev
        end

        unless pagy.page == pagy.pages
          pages[:last] = pagy.pages if options[:include_total]
          pages[:next] = pagy.next
        end
      end
    end

    def paginate_with_kaminari(collection, options, paginate_array_options = {})
      if Kaminari.config.max_per_page && options[:per_page] > Kaminari.config.max_per_page
        options[:per_page] = Kaminari.config.max_per_page
      elsif options[:per_page] <= 0
        options[:per_page] = get_default_per_page_for_kaminari(collection)
      end

      collection = Kaminari.paginate_array(collection, paginate_array_options) if collection.is_a?(Array)
      collection = collection.page(options[:page]).per(options[:per_page])
      collection.without_count if !collection.is_a?(Array) && !options[:include_total]
      [collection, nil]
    end

    def paginate_with_will_paginate(collection, options)
      if options[:per_page] <= 0
        options[:per_page] = default_per_page_for_will_paginate(collection)
      end

      collection = if defined?(Sequel::Dataset) && collection.kind_of?(Sequel::Dataset)
        collection.paginate(options[:page], options[:per_page])
      else
        supported_options = [:page, :per_page, :total_entries]
        options = options.dup.keep_if { |k,v| supported_options.include?(k.to_sym) }
        collection.paginate(options)
      end

      [collection, nil]
    end

    def get_default_per_page_for_kaminari(collection)
      default = Kaminari.config.default_per_page
      extract_per_page_from_model(collection, :default_per_page) || default
    end

    def default_per_page_for_will_paginate(collection)
      default = WillPaginate.per_page
      extract_per_page_from_model(collection, :per_page) || default
    end

    def extract_per_page_from_model(collection, accessor)
      klass = if collection.respond_to?(:klass)
        collection.klass
      else
        collection.first.class
      end

      return unless klass.respond_to?(accessor)
      klass.send(accessor)
    end
  end
end

require 'api-pagination/hooks'
