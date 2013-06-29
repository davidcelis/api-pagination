require 'api-pagination/version'
require 'kaminari'

module ApiPagination
  protected
    def paginate(scope)
      query_params = request.query_parameters
      scope        = instance_variable_get(:"@#{scope}")
      url          = request.original_url.sub(/\?.*$/, '')
      pages        = {}
      links        = []

      unless scope.first_page?
        pages[:first] = 1
        pages[:prev]  = scope.current_page - 1
      end

      unless scope.last_page?
        pages[:last] = scope.total_pages
        pages[:next] = scope.current_page + 1
      end

      pages.each do |k, v|
        new_params = query_params.merge({ :page => v })
        links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
      end

      headers['Link'] = links.join(', ')
    end
end

ActionController::Base.send(:include, ApiPagination) if defined?(ActionController::Base)
ActionController::API.send(:include, ApiPagination)  if defined?(ActionController::API)
