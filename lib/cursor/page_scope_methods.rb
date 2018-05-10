module Cursor
  module PageScopeMethods
    def per(num)
      if (n = num.to_i) <= 0
        self
      elsif max_per_page && max_per_page < n
        limit(max_per_page)
      else
        limit(n)
      end
    end

    def next_cursor
      @_next_cursor ||= last.try!(:id)
    end

    def prev_cursor
      @_prev_cursor ||= first.try!(:id)
    end

    def next_url(request_url)
      direction == :after ?
        after_url(request_url, next_cursor) :
        before_url(request_url, next_cursor)
    end

    def prev_url(request_url)
      direction == :after ?
        before_url(request_url, prev_cursor) :
        after_url(request_url, prev_cursor)
    end

    def before_url(request_url, cursor)
      base, params = url_parts(request_url)
      params.merge!('before' => cursor) unless cursor.nil?
      params.to_query.length > 0 ? "#{base}?#{CGI.unescape(params.to_query)}" : base
    end

    def after_url(request_url, cursor)
      base, params = url_parts(request_url)
      params.merge!('after' => cursor) unless cursor.nil?
      params.to_query.length > 0 ? "#{base}?#{CGI.unescape(params.to_query)}" : base
    end

    def url_parts(request_url)
      base, params = request_url.split('?', 2)
      params = Rack::Utils.parse_nested_query(params || '')
      params.stringify_keys!
      params.delete('before')
      params.delete('after')
      [base, params]
    end

    def direction
      return :after if prev_cursor.nil? && next_cursor.nil?
      @_direction ||= prev_cursor < next_cursor ? :after : :before
    end

    def pagination(request_url)
      {}.tap do |h|
        h[:prev] = prev_url(request_url) unless prev_cursor.nil?
        h[:next] = next_url(request_url) unless next_cursor.nil?
      end
    end
  end
end
