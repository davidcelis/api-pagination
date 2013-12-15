module Rails
  module Pagination
    protected

      def paginate(scope)
        links = (headers['Link'] || "").split(',').map(&:strip)

        scope = instance_variable_get(:"@#{scope}")
        url   = request.original_url.sub(/\?.*$/, '')
        pages = {}

        unless scope.first_page?
          pages[:first] = 1
          pages[:prev]  = scope.current_page - 1
        end

        unless scope.last_page?
          pages[:last] = scope.total_pages
          pages[:next] = scope.current_page + 1
        end

        pages.each do |k, v|
          new_params = request.query_parameters.merge(:page => v)
          links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
        end

        headers['Link'] = links.join(', ') unless links.empty?

        return scope
      end
  end
end
