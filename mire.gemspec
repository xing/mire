# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mire/version'

Gem::Specification.new do |spec|
  spec.name          = 'mire'
  spec.version       = Mire::VERSION
  spec.authors       = ['Marcus Lankenau']
  spec.email         = ['marcus.lankenau@xing.com']
  spec.summary       = 'Analyzes a ruby project.'
  spec.description   = <<-TEXT
    Analyzes a ruby project and help you to find dependencies, call stacks and
    unused methods.
  TEXT
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'parser'
  spec.add_runtime_dependency 'OptionParser'
  spec.add_runtime_dependency 'ruby-progressbar'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~>  3.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
