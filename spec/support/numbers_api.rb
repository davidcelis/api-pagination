require 'grape'
require 'api-pagination'

class NumbersAPI < Grape::API
  format :json

  desc 'Return some paginated set of numbers'
  paginate :per_page => 10, :max_per_page => 25 
  params do
    requires :count, :type => Integer
    optional :with_headers, :default => false, :type => Boolean
  end
  get :numbers do
    if params[:with_headers]
      url   = request.url.sub(/\?.*/, '')
      query = Rack::Utils.parse_query(request.query_string)
      query.delete('with_headers')
      header 'Link', %(<#{url}?#{query.to_query}>; rel="without")
    end

    paginate (1..params[:count]).to_a
  end
end
