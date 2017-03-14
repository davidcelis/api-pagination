require 'active_support/configurable'

module Cursor
  # Configures global settings for Divination
  #   Cursor.configure do |config|
  #     config.default_per_page = 10
  #   end
  def self.configure(&block)
    yield @config ||= Cursor::Configuration.new
  end

  # Global settings for Cursor
  def self.config
    @config
  end

  class Configuration #:nodoc:
    include ActiveSupport::Configurable
    config_accessor :default_per_page
    config_accessor :max_per_page

    def param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end
  end

  configure do |config|
    config.default_per_page = 25
    config.max_per_page = nil
  end
end
