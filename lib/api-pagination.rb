require 'api-pagination/hooks'
require 'api-pagination/version'

module ApiPagination
  class << self
    attr_writer :kaminari
    attr_writer :will_paginate

    def kaminari?() !!@kaminari end
    def will_paginate?() !!@will_paginate end

    def paginate(collection, options = {}, &block)
      options[:page]     ||= 1
      options[:per_page] ||= 10

      if ApiPagination.kaminari?
        collection.page(options[:page]).per(options[:per_page]).tap(&block)
      elsif ApiPagination.will_paginate?
        collection.paginate(:page => options[:page], :per_page => options[:per_page]).tap(&block)
      end
    end

    def pages_from(collection)
      {}.tap do |pages|
        unless collection.first_page?
          pages[:first] = 1
          pages[:prev]  = collection.current_page - 1
        end

        unless collection.last_page?
          pages[:last] = collection.total_pages
          pages[:next] = collection.current_page + 1
        end
      end
    end
  end
end

ApiPagination::Hooks.init
