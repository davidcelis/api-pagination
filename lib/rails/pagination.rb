module Rails
  module Pagination
    protected

    def paginate(*options_or_collection)
      options    = options_or_collection.extract_options!
      collection = options_or_collection.first

      return _paginate_collection(collection, options) if collection

      collection = options[:json] || options[:xml]
      collection = _paginate_collection(collection, options)

      options[:json] = collection if options[:json]
      options[:xml]  = collection if options[:xml]

      render options
    end

    def paginate_with(collection)
      respond_with _paginate_collection(collection)
    end

    private

    def _paginate_collection(collection, options={})
      options[:page] = ApiPagination.config.page_param(params)
      options[:per_page] ||= ApiPagination.config.per_page_param(params)

      collection, pagy = ApiPagination.paginate(collection, options)

      # links = (headers['Link'] || '').split(',').map(&:strip)
      #    = base_url + request.path_info
      pages = ApiPagination.pages_from(pagy || collection, options)
      total_pages = pages.last

      # pages.each do |k, v|
        # new_params = request.query_parameters.merge(:page => v)
        # links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
      # end

      total_header    = ApiPagination.config.total_header
      per_page_header = ApiPagination.config.per_page_header
      page_header     = ApiPagination.config.page_header
      include_total   = ApiPagination.config.include_total

      # headers['Link'] = links.join(', ') unless links.empty?
      headers[per_page_header] = options[:per_page].to_s
      headers[page_header] = options[:page].to_s unless page_header.nil?
      headers[total_header] = total_count(pagy || collection, options).to_s if include_total
      headers[total_pages_header] = options[:total_pages].to_s

      return collection
    end

    def total_count(collection, options)
      total_count = if ApiPagination.config.paginator == :kaminari
        paginate_array_options = options[:paginate_array_options]
        paginate_array_options[:total_count] if paginate_array_options
      end
      total_count || ApiPagination.total_from(collection)
    end

    def base_url
      ApiPagination.config.base_url || request.base_url
    end
  end
end
