begin; require 'grape'; rescue LoadError; end
if defined?(Grape::API)
  require 'grape/pagination'
  Grape::API.send(:include, Grape::Pagination)
end

begin; require 'kaminari';      rescue LoadError; end
begin; require 'will_paginate'; rescue LoadError; end

unless defined?(Kaminari) || defined?(WillPaginate::CollectionMethods)
  Kernel.warn <<-WARNING.gsub(/^\s{4}/, '')
    Warning: api-pagination relies on either Kaminari or WillPaginate. Please
    install either dependency by adding one of the following to your Gemfile:

    gem 'kaminari'
    gem 'will_paginate'
  WARNING
end

require 'api-pagination/railtie' if defined?(Rails)
