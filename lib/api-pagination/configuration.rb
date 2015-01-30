module ApiPagination
  class Configuration
    attr_reader :paginator

    attr_accessor :total_header

    attr_accessor :per_page_header

    def configure(&block)
      yield self
    end

    def initialize
      @total_header    = 'Total'
      @per_page_header = 'Per-Page'
      set_paginator
    end

    def paginator=(paginator)
      case paginator
      when :kaminari
        use_kaminari
      when :will_paginate
        use_will_paginate
      else
        raise StandardError, "Unknown paginator: #{paginator}"
      end
    end

    private

    def set_paginator
      if defined?(Kaminari) && defined?(WillPaginate::CollectionMethods)
        Kernel.warn <<-WARNING
Warning: api-pagination relies on either Kaminari or WillPaginate, but both are
currently active. If possible, you should remove one or the other. If you can't,
you must configure api-pagination on your own. For example:

ApiPagination.configure do |config|
  config.paginator = Kaminari
end

WARNING
      elsif defined?(Kaminari)
        use_kaminari and return
      elsif defined?(WillPaginate::CollectionMethods)
        use_will_paginate and return
      end

      begin
        require 'kaminari'
        use_kaminari and return
      rescue LoadError
      end

      begin
        require 'will_paginate'
        use_will_paginate and return
      rescue LoadError
      end

      Kernel.warn <<-WARNING
Warning: api-pagination relies on either Kaminari or WillPaginate. Please
install either dependency by adding one of the following to your Gemfile:

gem 'kaminari'
gem 'will_paginate'

WARNING
    end

    def use_kaminari
      require 'kaminari/models/array_extension'
      @paginator = :kaminari
    end

    def use_will_paginate
      WillPaginate::CollectionMethods.module_eval do
        def first_page?() !previous_page end
        def last_page?() !next_page end
      end

      @paginator = :will_paginate
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end
    alias :configuration :config
  end
end
