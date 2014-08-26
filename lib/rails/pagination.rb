module Rails
  module Pagination
    protected

    def paginate(options)
      collection = options[:json] || options[:xml]

      collection     = _paginate_collection(collection, options)
      options[:json] = collection if options[:json]
      options[:xml]  = collection if options[:xml]

      render options
    end

    def paginate_with(collection)
      respond_with _paginate_collection(collection)
    end

    private

    def _paginate_collection(collection, options={})
      all = options.delete(:all)

      options = {
        :page     => params[:page],
        :per_page => (options.delete(:per_page) || params[:per_page])
      }
      collection = ApiPagination.paginate(collection, options)

      links = (headers['Link'] || "").split(',').map(&:strip)
      url   = request.original_url.sub(/\?.*$/, '')
      pages = ApiPagination.pages_from(collection)

      if all && pages[:next].present? && pages[:last].present?
        (pages[:next].to_i..pages[:last].to_i).each do |page_num|
          new_params = request.query_parameters.merge(:page => page_num)
          links << %(<#{url}?#{new_params.to_param}>)
        end
      else
        pages.each do |k, v|
          new_params = request.query_parameters.merge(:page => v)
          links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
        end
      end

      headers['Link']  = links.join(', ') unless links.empty?
      headers['Total'] = ApiPagination.total_from(collection)

      return collection
    end
  end
end

