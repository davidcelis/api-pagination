# api-pagination

[![Build Status][travis-badge]][travis] [![Coverage][coveralls-badge]][coveralls] [![Climate][code-climate-badge]][code-climate] [![Dependencies][gemnasium-badge]][gemnasium] [![gittip][gittip-badge]][gittip]

Paginate in your headers, not in your response body.
This follows the proposed [RFC-5988](http://tools.ietf.org/html/rfc5988) standard for Web linking.

## Installation

In your `Gemfile`:

```ruby
# Requires Rails (Rails-API is also supported), or Grape
# v0.10.0 or later. If you're on an earlier version of
# Grape, use api-pagination ~> 3.1
gem 'rails', '>= 3.0.0'
gem 'rails-api'
gem 'grape', '>= 0.10.0'

# Then choose your preferred paginator from the following:
gem 'kaminari'
gem 'will_paginate'

# Finally...
gem 'api-pagination'
```

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

This will pull your collection from the `json` or `xml` option, paginate it for you using `params[:page]` and `params[:per_page]`, render Link headers, and call `ActionController::Base#render` with whatever you passed to `paginate`. This should work well with [ActiveModel::Serializers](https://github.com/rails-api/active_model-serializers). However, if you need more control over what is done with your paginated collection, you can pass the collection directly to `paginate` instead of in a way that mimics `render`:

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

This will avoid implicitly calling `render` at the end. Instead, `paginate` will simply set up the headers and return your collection so you can do whatever you want with it.

Note that the collection sent to `paginate` _must_ respond to your paginator's methods. For Kaminari, `Kaminari.paginate_array` will be called for you behind-the-scenes. For WillPaginate, you're out of luck unless you call `require 'will_paginate/array'` somewhere. Because this pollutes `Array`, it won't be done for you automatically.

## Grape

With Grape, `paginate` is used to declare that your endpoint takes a `:page` and `:per_page` param. Inside your API endpoint, it simply takes your collection:

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
    paginate per_page: 10
    get :cast do
      paginate Movie.find(params[:id]).actors
    end
  end
end
```

Then `curl --include` to see your header-based pagination in action:

```bash
$ curl --include 'https://localhost:3000/movies?page=5'
HTTP/1.1 200 OK
Link: <http://localhost:3000/movies?page=1>; rel="first",
  <http://localhost:3000/movies?page=173>; rel="last",
  <http://localhost:3000/movies?page=6>; rel="next",
  <http://localhost:3000/movies?page=4>; rel="prev"
Total: 4321
# ...
```

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
