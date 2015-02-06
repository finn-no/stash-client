# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stash/client/version'

Gem::Specification.new do |spec|
  spec.name          = "stash-client"
  spec.version       = Stash::Client::VERSION
  spec.authors       = ["Jari Bakken"]
  spec.email         = ["jari.bakken@gmail.com"]
  spec.description   = %q{Atlassian Stash Client}
  spec.summary       = %q{Atlassian Stash Client}
  spec.homepage      = "http://github.com/finn-no/stash-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"

  spec.add_dependency 'faraday'
  spec.add_dependency 'addressable'
end
