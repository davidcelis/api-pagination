require_relative 'config'
require_relative 'configuration_methods'
require_relative 'page_scope_methods'

module Cursor
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    class_methods do
      cattr_accessor :total_count
    end

    included do
      self.send(:include, Cursor::ConfigurationMethods)

      def self.cursor_page(options = {})
        (options || {}).to_hash.symbolize_keys!
        options[:direction] = options.keys.include?(:after) ? :after : :before

        cursor_id = options[options[:direction]]
        self.total_count = self.count
        on_cursor(cursor_id, options[:direction]).
          in_direction(options[:direction]).
          limit(options[:per_page] || default_per_page).
          extending(Cursor::PageScopeMethods)
      end

      def self.on_cursor(cursor_id, direction)
        if cursor_id.nil?
          where(nil)
        else
          where(["#{self.table_name}.id #{direction == :after ? '>' : '<'} ?", cursor_id])
        end
      end

      def self.in_direction(direction)
        reorder("#{self.table_name}.id #{direction == :after ? 'ASC' : 'DESC'}")
      end
    end
  end
end
