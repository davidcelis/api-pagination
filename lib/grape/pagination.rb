module Grape
  module Pagination
    def self.included(base)
      Grape::Endpoint.class_eval do
        def paginate(collection)
          options = {
            :page     => params[:page],
            :per_page => (params[:per_page] || settings[:per_page])
          }
          collection = ApiPagination.paginate(collection, options)
          links      = (header['Link'] || "").split(',').map(&:strip)
          pages      = ApiPagination.pages_from(collection)

          url = request.url.sub(/\?.*$/, '')
          url = URI.parse(url).request_uri if settings[:relative_uri]

          if settings[:exclude_base_path]
            base_path_regexp = Regexp.new("^" + settings[:exclude_base_path])
            url = url.sub(base_path_regexp, "")
          end

          pages.each do |k, v|
            old_params = Rack::Utils.parse_query(request.query_string)
            new_params = old_params.merge('page' => v)
            links << %(<#{url}?#{new_params.to_param}>; rel="#{k}")
          end

          header 'Link', links.join(', ') unless links.empty?
          header 'Total', ApiPagination.total_from(collection)

          return collection
        end
      end

      base.class_eval do
        def self.paginate(options = {})
          # URIs can also be relative, useful when using API proxies.
          #
          # From RFC 5988 (Web Linking):
          # "If the URI-Reference is relative, parsers MUST resolve it
          # as per [RFC3986], Section 5.""
          set :relative_uri, (options[:relative_uri] || false)

          # When using API proxies, you probably want to hide base path
          # from returned links since proxies point to your API base path
          # directly making its own resources not have such base path.
          #
          # E.g.
          # If your application has the following API resource:
          #   mywebsite.example.com/api/v1/resource.json
          # And that's accessible though the following API proxy resource:
          #   myproxy.example.com/v1/resource.json
          # You don't want links to return '/api/v1/...', but '/v1/...'.
          set :exclude_base_path, (options[:exclude_base_path] || false)

          set :per_page, (options[:per_page] || 25)
          params do
            optional :page,     :type => Integer, :default => 1,
                                :desc => 'Page of results to fetch.'
            optional :per_page, :type => Integer,
                                :desc => 'Number of results to return per page.'
          end
        end
      end
    end
  end
end
