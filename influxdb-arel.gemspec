# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'influxdb/arel/version'

Gem::Specification.new do |spec|
  spec.name          = "influxdb-arel"
  spec.version       = Influxdb::Arel::VERSION
  spec.authors       = ["undr"]
  spec.email         = ["undr@yandex.ru"]
  spec.summary       = %q{Influxdb SQL AST manager.}
  spec.description   = %q{Influxdb::Arel is a SQL AST manager for Influxdb dialect.}
  spec.homepage      = "https://github.com/undr/influxdb-arel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
