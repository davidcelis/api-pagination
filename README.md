# api-pagination

Paginate in your headers, not in your response body.
This follows the proposed [RFC-8288](https://tools.ietf.org/html/rfc8288) standard for Web linking.

## Installation

In your `Gemfile`:

```ruby
# Requires Rails (Rails-API is also supported), or Grape
# v0.10.0 or later. If you're on an earlier version of
# Grape, use api-pagination v3.0.2.
gem 'rails', '>= 3.0.0'
gem 'rails-api'
gem 'grape', '>= 0.10.0'

# Then choose your preferred paginator from the following:
gem 'pagy'
gem 'kaminari'
gem 'will_paginate'

# Finally...
gem 'api-pagination'
```

## Configuration (optional)

By default, api-pagination will detect whether you're using Pagy, Kaminari, or WillPaginate, and it will name headers appropriately. If you want to change any of the configurable settings, you may do so:

```ruby
ApiPagination.configure do |config|
  # If you have more than one gem included, you can choose a paginator.
  config.paginator = :kaminari # or :will_paginate

  # By default, this is set to 'Total'
  config.total_header = 'X-Total'

  # By default, this is set to 'Per-Page'
  config.per_page_header = 'X-Per-Page'

  # Optional: set this to add a header with the current page number.
  config.page_header = 'X-Page'

  # Optional: set this to add other response format. Useful with tools that define :jsonapi format
  config.response_formats = [:json, :xml, :jsonapi]

  # Optional: what parameter should be used to set the page option
  config.page_param = :page
  # or
  config.page_param do |params|
    params[:page][:number] if params[:page].is_a?(ActionController::Parameters)
  end

  # Optional: what parameter should be used to set the per page option
  config.per_page_param = :per_page
  # or
  config.per_page_param do |params|
    params[:page][:size] if params[:page].is_a?(ActionController::Parameters)
  end

  # Optional: Include the total and last_page link header
  # By default, this is set to true
  # Note: When using kaminari, this prevents the count call to the database
  config.include_total = false
end
```

### Pagy-specific configuration

Pagy does not have a built-in way to specify a maximum number of items per page, but `api-pagination` will check if you've set a `:max_per_page` variable. To configure this, you can use the following code somewhere in an initializer:

```ruby
Pagy::DEFAULT[:max_per_page] = 100
```

If left unconfigured, clients can request as many items per page as they wish, so it's highly recommended that you configure this.

## Rails

In your controller, provide a pageable collection to the `paginate` method. In its most convenient form, `paginate` simply mimics `render`:

```ruby
class MoviesController < ApplicationController
  # GET /movies
  def index
    movies = Movie.all # Movie.scoped if using ActiveRecord 3.x

    paginate json: movies
  end

  # GET /movies/:id/cast
  def cast
    actors = Movie.find(params[:id]).actors

    # Override how many Actors get returned. If unspecified,
    # params[:per_page] (which defaults to 25) will be used.
    paginate json: actors, per_page: 10
  end
end
```

This will pull your collection from the `json` or `xml` option, paginate it for you using `params[:page]` and `params[:per_page]`, render Link headers, and call `ActionController::Base#render` with whatever you passed to `paginate`. This should work well with [ActiveModel::Serializers](https://github.com/rails-api/active_model_serializers). However, if you need more control over what is done with your paginated collection, you can pass the collection directly to `paginate` to receive a paginated collection and have your headers set. Then, you can pass that paginated collection to a serializer or do whatever you want with it:

```ruby
class MoviesController < ApplicationController
  # GET /movies
  def index
    movies = paginate Movie.all

    render json: MoviesSerializer.new(movies)
  end

  # GET /movies/:id/cast
  def cast
    actors = paginate Movie.find(params[:id]).actors, per_page: 10

    render json: ActorsSerializer.new(actors)
  end
end
```

Note that the collection sent to `paginate` _must_ respond to your paginator's methods. This is typically fine unless you're dealing with a stock Array. For Kaminari, `Kaminari.paginate_array` will be called for you behind-the-scenes. For WillPaginate, you're out of luck unless you call `require 'will_paginate/array'` somewhere. Because this pollutes `Array`, it won't be done for you automatically. If you use Pagy, it doesn't matter, because Pagy doesn't care what you're paginating. It will just work, as long as the collection responds to `count`.

**NOTE:** In versions 4.4.0 and below, the `Rails::Pagination` module would end up included in `ActionController::Base` even if `ActionController::API` was defined. As of version 4.5.0, this is no longer the case. If for any reason your API controllers cannot easily changed be changed to inherit from `ActionController::API` instead, you can manually include the module:

```ruby
class API::ApplicationController < ActionController::Base
  include Rails::Pagination
end
```

## Grape

With Grape, `paginate` is used to declare that your endpoint takes a `:page` and `:per_page` param. You can also directly specify a `:max_per_page` that users aren't allowed to go over. Then, inside your API endpoint, it simply takes your collection:

```ruby
class MoviesAPI < Grape::API
  format :json

  desc 'Return a paginated set of movies'
  paginate
  get do
    # This method must take an ActiveRecord::Relation
    # or some equivalent pageable set.
    paginate Movie.all
  end

  route_param :id do
    desc "Return one movie's cast, paginated"
    # Override how many Actors get returned. If unspecified,
    # params[:per_page] (which defaults to 25) will be used.
    # There is no default for `max_per_page`.
    paginate per_page: 10, max_per_page: 200
    get :cast do
      paginate Movie.find(params[:id]).actors
    end

    desc "Return one movie's awards, paginated"
    # Enforce max_per_page value will add the alowed values
    # to the swagger docs, and cause grape to return an error
    # if outside that range
    paginate per_page: 10, max_per_page: 200, enforce_max_per_page: true
    get :awards do
      paginate Movie.find(params[:id]).awards
    end
  end
end
```

## Headers

Then `curl --include` to see your header-based pagination in action:

```bash
$ curl --include 'https://localhost:3000/movies?page=5'
HTTP/1.1 200 OK
Link: <http://localhost:3000/movies?page=1>; rel="first",
  <http://localhost:3000/movies?page=173>; rel="last",
  <http://localhost:3000/movies?page=6>; rel="next",
  <http://localhost:3000/movies?page=4>; rel="prev"
Total: 4321
Per-Page: 10
# ...
```

## A Note on Kaminari and WillPaginate

api-pagination requires either Kaminari or WillPaginate in order to function, but some users may find themselves in situations where their application includes both. For example, you may have included [ActiveAdmin][activeadmin] (which uses Kaminari for pagination) and WillPaginate to do your own pagination. While it's suggested that you remove one paginator gem or the other, if you're unable to do so, you _must_ configure api-pagination explicitly:

```ruby
ApiPagination.configure do |config|
  config.paginator = :will_paginate
end
```

If you don't do this, an annoying warning will print once your app starts seeing traffic. You should also configure Kaminari to use a different name for its `per_page` method (see https://github.com/activeadmin/activeadmin/wiki/How-to-work-with-will_paginate):

```ruby
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end
```

[activeadmin]: https://github.com/activeadmin/activeadmin
[kaminari]: https://github.com/amatsuda/kaminari
[will_paginate]: https://github.com/mislav/will_paginate

[travis]: https://travis-ci.org/davidcelis/api-pagination
[travis-badge]: http://img.shields.io/travis/davidcelis/api-pagination/master.svg
[coveralls]: https://coveralls.io/r/davidcelis/api-pagination
[coveralls-badge]: http://img.shields.io/coveralls/davidcelis/api-pagination/master.svg
[code-climate]: https://codeclimate.com/github/davidcelis/api-pagination
[code-climate-badge]: http://img.shields.io/codeclimate/github/davidcelis/api-pagination.svg
[gemnasium]: http://gemnasium.com/davidcelis/api-pagination
[gemnasium-badge]: http://img.shields.io/gemnasium/davidcelis/api-pagination.svg
[gittip]: https://gittip.com/davidcelis
[gittip-badge]: http://img.shields.io/gittip/davidcelis.svg
