require 'bundler/setup'
Bundler.setup

require 'global_registry'
require 'active_support/core_ext/string'
require 'webmock/rspec'

RSpec.configure do |_config|
  # some config here

end

GlobalRegistry.configure do |config|
  config.access_token = 'asdf'
  config.base_url = 'google.com/'
end