require 'active_support/core_ext/string/inflections'
require 'global_registry/base'

Dir[File.dirname(__FILE__) + '/global_registry/*.rb'].each do |file|
  require file
end

module GlobalRegistry
  class << self
    attr_accessor :base_url, :access_token

    def configure
      yield self
    end

    def base_url
      @base_url ||= "https://api.leadingwithinformation.com/"
    end

  end
end

