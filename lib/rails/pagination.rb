module Rails
  module Pagination
    protected

    def paginate(options)
      collection = options[:json] || options[:xml]

      collection     = _paginate_collection(collection)
      options[:json] = collection if options[:json]
      options[:xml]  = collection if options[:xml]

      render options
    end

    def paginate_with(collection)
      respond_with _paginate_collection(collection)
    end

    private

    def _paginate_collection(collection)
      block = Proc.new do |collection|
        links = (headers['Link'] || "").split(',').map(&:strip)
        url   = request.original_url.sub(/\?.*$/, '')
        pages = ApiPagination.pages_from(collection)

        pages.each do |k, v|
          new_params = request.query_parameters.merge(:page => v)
          links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
        end

        headers['Link']  = links.join(', ') unless links.empty?
        headers['Total'] = ApiPagination.total_from(collection)
      end

      ApiPagination.paginate(collection, params, &block)
    end
  end
end

