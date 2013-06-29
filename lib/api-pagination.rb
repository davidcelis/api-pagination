require 'api-pagination/version'
require 'kaminari'

module ApiPagination
  protected
    def paginate(scope)
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

      links = pages.map do |k, v|
        new_params = request.query_parameters.merge({ :page => v })
        %(<#{url}?#{new_params.to_param}>; rel="#{k}")
      end

      headers['Link'] = links.join(', ')
    end
end

ActionController::Base.send(:include, ApiPagination) if defined?(ActionController::Base)
ActionController::API.send(:include, ApiPagination)  if defined?(ActionController::API)
