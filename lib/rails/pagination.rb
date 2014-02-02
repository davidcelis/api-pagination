module Rails
  module Pagination
    protected

      def paginate(collection)
        collection = instance_variable_get(:"@#{collection}")

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
