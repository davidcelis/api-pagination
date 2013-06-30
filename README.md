# api-pagination [![Build Status](https://travis-ci.org/davidcelis/api-pagination.png)](https://travis-ci.org/davidcelis/api-pagination)

Put pagination info in a Link header, not the response body.

## Installation

In your `Gemfile`:

```ruby
# Requires Rails and is compatible with Rails-API.
gem 'rails', '>= 3.0.0'
# gem 'rails-api'

# Then choose your preferred paginator from the following:
gem 'kaminari'
gem 'will_paginate'

# Finally...
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

While the above examples use [Kaminari][kaminari], api-pagination is also compatible with [will_paginate][will_paginate]. See either gem's README for more info on their respective usages.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[kaminari]: https://github.com/amatsuda/kaminari
[will_paginate]: https://github.com/mislav/will_paginate
