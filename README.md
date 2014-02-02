# api-pagination [![Build Status](https://travis-ci.org/davidcelis/api-pagination.png)](https://travis-ci.org/davidcelis/api-pagination)

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

## Testing

```bash
PAGINATOR=kaminari bundle exec rspec
PAGINATOR=will_paginate bundle exec rspec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes and tests (`git commit -am 'Add some feature'`)
4. Run the tests (`KAMINARI=true bundle exec rspec; WILL_PAGINATE=true bundle exec rspec`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

[kaminari]: https://github.com/amatsuda/kaminari
[will_paginate]: https://github.com/mislav/will_paginate
