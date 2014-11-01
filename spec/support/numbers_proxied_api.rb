require 'grape'
require 'api-pagination'

class NumbersProxiedAPI < Grape::API
  format :json

  # This namespace is here simulate that the API is nested in a directory.
  # When using an API proxy, this base path vanishes since the proxy host
  # is the new base. That's why we have 'exclude_base_path'.
  namespace :api do
    desc 'Return some paginated set of numbers'
    paginate :per_page          => 10,
             :exclude_base_path => "/api",
             :relative_uri      => true
    params do
      requires :count, :type => Integer
    end
    get :numbers do
      paginate (1..params[:count]).to_a
    end
  end
end
