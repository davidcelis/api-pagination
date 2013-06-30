# api-pagination [![Build Status](https://travis-ci.org/davidcelis/api-pagination.png)](https://travis-ci.org/davidcelis/api-pagination)

Put pagination info in a Link header, not the response body.

## Installation

In your `Gemfile`:

```ruby
# Requires 'rails', '>= 3.0.0' and is compatible with 'rails-api'
gem 'api-pagination'
```

## Usage

In your controllers:

```ruby
class MoviesController < ApplicationController
  # Uses the @movies and @actors variables set below
  after_filter only: [:index] { paginate(:movies) }
  after_filter only: [:cast]  { paginate(:actors) }

  # GET /movies
  def index
    @movies = Movie.page(params[:page])

    render json: @movies
  end

  # GET /movies/:id/cast
  def cast
    @movie  = Movie.find(params[:id])
    @actors = @movie.actors.page(params[:page])

    render json: @actors
  end
end
```

Then `curl --include` to see your Link header pagination in action:

```bash
$ curl --include 'https://localhost:3000/movies?page=5'
HTTP/1.1 200 OK
Link: <http://localhost:3000/movies?page=1>; rel="first">,
  <http://localhost:3000/movies?page=173>; rel="last">,
  <http://localhost:3000/movies?page=6>; rel="next">,
  <http://localhost:3000/movies?page=4>; rel="prev">
# ...
```

api-pagination uses [Kaminari][kaminari] under the hood for paginating your ActiveRecord relations. See Kaminari's [documentation][kaminari-docs] for more information on its usage.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[kaminari]: https://github.com/amatsuda/kaminari
[kaminari-docs]: http://rubydoc.info/github/amatsuda/kaminari/frames
