# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'global_registry/version'

Gem::Specification.new do |gem|
  gem.name          = "global_registry"
  gem.version       = GlobalRegistry::VERSION
  gem.authors       = ["Josh Starcher"]
  gem.email         = ["josh.starcher@gmail.com"]
  gem.description   = %q{This gem wraps an API for the Global Registry.}
  gem.summary       = %q{Push and pull data from the Global Registry}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('rest-client', '~> 1.6.7')
  gem.add_dependency('oj', '~> 2.1.0')
  gem.add_dependency('activesupport')
  gem.add_dependency('retryable-rb', '~> 1.1.0')

end
