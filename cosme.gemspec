# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cosme/version'

Gem::Specification.new do |spec|
  spec.name          = 'cosme'
  spec.version       = Cosme::VERSION
  spec.authors       = ['YOSHIDA Hiroki']
  spec.email         = ['hyoshida@appirits.com']

  spec.summary       = 'A simple solution to customize views in your Ruby on Rails application.'
  spec.description   = 'Cosme is a simple solution to customize views of any template engine in your Ruby on Rails application.'
  spec.homepage      = 'https://github.com/appirits/cosme#cosme'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionview', '>= 4.0.0', '< 5'
  spec.add_dependency 'coffee-rails', '>= 3.2.2', '< 4.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
end
