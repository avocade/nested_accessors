# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nested_accessors/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oskar Boethius Lissheim"]
  gem.email         = ["oskar@OLBproductions.com"]
  gem.homepage      = "http://OLBproductions.com"
  gem.description   = %q{Quickly add serialized, nested hash accessors in ActiveRecord model objects}
  gem.summary       = %q{Without having to write your own accessor methods for getting at serialized hash properties}
  gem.homepage      = "http://OLBproductions.com"
  gem.license      = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nested_accessors"
  gem.require_paths = ["lib"]
  gem.version       = NestedAccessors::VERSION

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "simple_mock"
  gem.add_development_dependency "minitest-colorize"
end
