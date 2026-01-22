require "active_support/core_ext/string/inflections"
require "global_registry/base"
require "global_registry/exceptions"

Dir[File.dirname(__FILE__) + "/global_registry/*.rb"].each do |file|
  require file
end

module GlobalRegistry
  class << self
    attr_accessor :access_token, :proxy_url
    attr_writer :base_url

    def configure
      yield self
    end

    def base_url
      @base_url ||= "https://api.global-registry.org/"
    end
  end
end
