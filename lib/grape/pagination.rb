module Grape
  module Pagination
    def self.included(base)
      Grape::Endpoint.class_eval do
        def paginate(collection)
          options = {
            :page     => params[:page],
            :per_page => (params[:per_page] || settings[:per_page]),
            :max_per_page => settings[:max_per_page]
          }
          collection = ApiPagination.paginate(collection, options)

          links = (header['Link'] || "").split(',').map(&:strip)
          url   = request.url.sub(/\?.*$/, '')
          pages = ApiPagination.pages_from(collection)

          old_params = Rack::Utils.parse_query(request.query_string)
          old_params['per_page'] = options[:per_page] if old_params['per_page']

          pages.each do |k, v|
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
          set :per_page, (options[:per_page] || 25)
          set :max_per_page, options[:max_per_page]
          params do
            optional :page,         :type => Integer, :default => 1,
                                    :desc => 'Page of results to fetch.'
            optional :per_page,     :type => Integer,
                                    :desc => 'Number of results to return per page.'
          end
        end
      end
    end
  end
end
