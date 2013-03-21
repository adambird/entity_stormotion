# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'entity_stormotion/version'

Gem::Specification.new do |spec|
  spec.name          = "entity_stormotion"
  spec.version       = EntityStormotion::VERSION
  spec.authors       = ["Adam Bird"]
  spec.email         = ["adam.bird@gmail.com"]
  spec.description   = %q{RubyMotion wrapper for the entity_store gem}
  spec.summary       = %q{RubyMotion wrapper for the entity_store gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'bubble-wrap'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
