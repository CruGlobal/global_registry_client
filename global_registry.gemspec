lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "global_registry/version"

Gem::Specification.new do |gem|
  gem.name = "global_registry"
  gem.version = GlobalRegistry::VERSION
  gem.authors = ["Josh Starcher"]
  gem.email = ["josh.starcher@gmail.com"]
  gem.description = "This gem wraps an API for the Global Registry."
  gem.summary = "Push and pull data from the Global Registry"
  gem.homepage = ""

  gem.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency("rest-client", ">= 1.6.7", "< 3.0.0")
  gem.add_dependency("oj", ">= 2.13")
  gem.add_dependency("oj_mimic_json")
  gem.add_dependency("activesupport", ">= 7.2.3")
  gem.add_dependency("retryable-rb", "~> 1.1")
  gem.add_dependency("addressable", "~> 2.4")
end
