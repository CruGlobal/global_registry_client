# -*- encoding: utf-8 -*-
# stub: retryable-rb 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "retryable-rb".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Robert Sosinski".freeze]
  s.date = "2011-04-17"
  s.description = "Easy to use DSL to retry code if an exception is raised.".freeze
  s.email = "email@robertsosinski.com".freeze
  s.extra_rdoc_files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.markdown".freeze, "lib/retryable.rb".freeze]
  s.files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.markdown".freeze, "lib/retryable.rb".freeze]
  s.homepage = "http://github.com/robertsosinski/retryable".freeze
  s.rdoc_options = ["--line-numbers".freeze, "--inline-source".freeze, "--title".freeze, "Retryable-rb".freeze, "--main".freeze, "README.markdown".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Easy to use DSL to retry code if an exception is raised.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_development_dependency(%q<echoe>.freeze, [">= 4.3.1"])
end
