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
      options = {
        :page     => params[:page],
        :per_page => (options.delete(:per_page) || params[:per_page])
      }
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

      headers['Link']          = links.join(', ') unless links.empty?
      headers[total_header]    = ApiPagination.total_from(collection) if include_total
      headers[per_page_header] = options[:per_page].to_s
      headers[page_header]     = options[:page].to_s unless page_header.nil?

      return collection
    end
  end
end
