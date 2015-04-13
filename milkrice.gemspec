# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'milkrice/version'

Gem::Specification.new do |spec|
  spec.name          = 'milkrice'
  spec.version       = Milkrice::VERSION
  spec.authors       = ['Marcus Lankenau']
  spec.email         = ['marcus.lankenau@xing.com']
  spec.summary       = 'analyzes your ruby project and help find dependencies, callstacks and unused methods'
  spec.description   = 'analyzes your ruby project and help find dependencies, callstacks and unused methods'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'OptionParser'
end
