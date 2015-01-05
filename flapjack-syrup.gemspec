# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flapjack/syrup/version'

Gem::Specification.new do |spec|
  spec.name          = 'flapjack-syrup'
  spec.version       = Flapjack::Syrup::VERSION
  spec.authors       = ['Geoff Hicks']
  spec.email         = ['ghicks@rmn.com']
  spec.summary       = 'flapjack-syrup: Create or manipulate objects in your Flapjack environment.'
  spec.homepage      = ''
  spec.license       = 'mit'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_development_dependency('rake', '~> 0.9.2')
  spec.add_dependency('gli')
  spec.add_dependency('flapjack-diner', '~> 1.0')
end
