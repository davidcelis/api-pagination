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
        :page         => params[:page],
        :per_page     => (options.delete(:per_page) || params[:per_page]),
        :max_per_page => options[:max_per_page]
      }
      collection = ApiPagination.paginate(collection, options)

      links = (headers['Link'] || "").split(',').map(&:strip)
      url   = request.original_url.sub(/\?.*$/, '')
      pages = ApiPagination.pages_from(collection)

      request.query_parameters[:per_page] = options[:per_page] if request.query_parameters[:per_page]

      pages.each do |k, v|
        new_params = request.query_parameters.merge(:page => v)
        links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
      end

      headers['Link']  = links.join(', ') unless links.empty?
      headers['Total'] = ApiPagination.total_from(collection)

      return collection
    end
  end
end

