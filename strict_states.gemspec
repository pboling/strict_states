# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strict_states/version'

Gem::Specification.new do |spec|
  spec.name          = "strict_states"
  spec.version       = StrictStates::VERSION
  spec.authors       = ["Peter Boling"]
  spec.email         = ["peter.boling@gmail.com"]

  spec.summary       = %q{Safely access state machine states with guarantee that there are no typos.}
  spec.description   = %q{Safely access state machine states with guarantee that there are no typos.  Compatible with all Ruby state machine libraries.}
  spec.homepage      = "https://github.com/pboling/strict_states"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie", ">= 3.4.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "rspec"
end
