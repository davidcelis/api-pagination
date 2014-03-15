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

In your controller:

```ruby
class MoviesController < ApplicationController
  # Uses the @movies and @actors variables set below.
  # This method must take an ActiveRecord::Relation
  # or some equivalent pageable set.
  after_filter only: [:index] { paginate(:movies) }
  after_filter only: [:cast]  { paginate(:actors) }

  # GET /movies
  def index
    @movies = Movie.all # Movie.scoped if using ActiveRecord 3.x

    render json: @movies
  end

  # GET /movies/:id/cast
  def cast
    @movie  = Movie.find(params[:id])
    @actors = @movie.actors

    # Override how many Actors get returned.
    params[:per_page] = 10

    render json: @actors
  end
end
```

## Grape

In your API endpoint:

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
