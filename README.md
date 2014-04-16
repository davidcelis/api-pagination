# api-pagination

[![Build Status][travis-badge]][travis] [![Coverage][coveralls-badge]][coveralls] [![Climate][code-climate-badge]][code-climate] [![Dependencies][gemnasium-badge]][gemnasium] [![gittip][gittip-badge]][gittip]

Paginate in your headers, not in your response body.

## Installation

In your `Gemfile`:

```ruby
# Requires Rails (Rails-API is also supported) or Grape.
gem 'rails', '>= 3.0.0'
gem 'rails-api'
gem 'grape'

# Then choose your preferred paginator from the following:
gem 'kaminari'
gem 'will_paginate'

# Finally...
gem 'api-pagination'
```

## Rails

In your controller, provide a pageable collection to the `paginate` method:

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

    # Override how many Actors get returned. The default is 10.
    paginate json: actors, per_page: 25
  end
end
```

`paginate` will:

1. Pull your collection from `json:` or `xml:`
2. Use `params[:page]` and `params[:per_page]` to paginate your collection for you
3. Use the paginated collection to render `Link` headers
4. Call `ActionController::Base#render` with whatever you passed to `paginate`.

The collection sent to `paginate` _must_ respond to your paginator's methods. For Kaminari, `Kaminari.paginate_array` will be called for you behind-the-scenes. For WillPaginate, you're out of luck unless you somewhere `require 'will_paginate/array'`. Because this pollutes `Array`, it won't be done for you automatically.

## Grape

Grape is similar, though `paginate` won't take options. Only your collection. In your API endpoint:

```ruby
class MoviesAPI < Grape::API
  format :json

  desc 'Return a paginated set of movies'
  paginate per_page: 25
  get :numbers do
    movies = Movie.all # Movie.scoped if using ActiveRecord 3.x

    # This method must take an ActiveRecord::Relation
    # or some equivalent pageable set.
    paginate movies
  end
end
```

Then `curl --include` to see your header-based pagination in action:

```bash
$ curl --include 'https://localhost:3000/movies?page=5'
HTTP/1.1 200 OK
Link: <http://localhost:3000/movies?page=1>; rel="first">,
  <http://localhost:3000/movies?page=173>; rel="last">,
  <http://localhost:3000/movies?page=6>; rel="next">,
  <http://localhost:3000/movies?page=4>; rel="prev">
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
