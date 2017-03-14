module Rails
  module Pagination
    protected

    def paginate(*options_or_collection)
      options    = options_or_collection.extract_options!
      collection = options_or_collection.first

      paginate_method = detect_pagination_method(options)
      return send(paginate_method, collection, options) if collection

      collection = options[:json] || options[:xml]
      collection = send(paginate_method, collection, options)

      options[:json] = collection if options[:json]
      options[:xml]  = collection if options[:xml]

      render options
    end

    def paginate_with(collection)
      respond_with _paginate_collection(collection)
    end

    def cursor_paginate(*options_or_collection)
      options = options_or_collection.extract_options!
      options.reverse_merge!(paginate_method: '_cursor_paginate_collection')
      options_or_collection << options
      paginate(*options_or_collection)
    end

    def cursor_paginate_with(collection)
      respond_with _cursor_paginate_collection(collection)
    end

    private

    def detect_pagination_method(options = {})
      options.delete(:paginate_method) || '_paginate_collection'
    end

    def _cursor_paginate_collection(collection, options={})
      options[:per_page] ||= ApiPagination.config.per_page_param(params)

      options[:before] = params[:before] if params.key?(:before)
      options[:after] = params[:after] if params.key?(:after)
      options[:per_page] ||= collection.default_per_page

      collection = collection.cursor_page(options)

      links = (headers['Link'] || "").split(',').map(&:strip)
      collection.pagination(request.original_url).each do |k, url|
        links << %(<#{url}>; rel="#{k}")
      end
      total_header    = ApiPagination.config.total_header
      per_page_header = ApiPagination.config.per_page_header
      include_total   = ApiPagination.config.include_total
      headers['Link'] = links.join(', ') unless links.empty?
      headers[per_page_header] = options[:per_page]
      headers[total_header] = collection.total_count if include_total

      collection
    end

    def _paginate_collection(collection, options={})
      options[:page] = ApiPagination.config.page_param(params)
      options[:per_page] ||= ApiPagination.config.per_page_param(params)

      collection = ApiPagination.paginate(collection, options)

      links = (headers['Link'] || "").split(',').map(&:strip)
      url   = request.original_url.sub(/\?.*$/, '')
      pages = ApiPagination.pages_from(collection)

      pages.each do |k, v|
        new_params = request.query_parameters.merge(:page => v)
        links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
      end

      total_header    = ApiPagination.config.total_header
      per_page_header = ApiPagination.config.per_page_header
      page_header     = ApiPagination.config.page_header
      include_total   = ApiPagination.config.include_total

      headers['Link'] = links.join(', ') unless links.empty?
      headers[per_page_header] = options[:per_page].to_s
      headers[page_header] = options[:page].to_s unless page_header.nil?
      headers[total_header] = total_count(collection, options).to_s if include_total

      return collection
    end

    def total_count(collection, options)
      total_count = if ApiPagination.config.paginator == :kaminari
        paginate_array_options = options[:paginate_array_options]
        paginate_array_options[:total_count] if paginate_array_options
      end
      total_count || ApiPagination.total_from(collection)
    end
  end
end
