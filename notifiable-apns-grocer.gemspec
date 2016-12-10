# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'notifiable/apns/grocer/version'

Gem::Specification.new do |spec|
  spec.name          = "notifiable-apns-grocer"
  spec.version       = Notifiable::Apns::Grocer::VERSION
  spec.authors       = ["Kamil Kocemba", "Matt Brooke-Smith"]
  spec.email         = ["kamil@futureworkshops.com", "matt@futureworkshops.com"]
  spec.homepage      = "http://www.futureworkshops.com"
  spec.description   = "Notifiable APNS plugin for Grocer"
  spec.summary       = "Notifiable APNS plugin for Grocer"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "notifiable-rails", ">=0.24.1"
  spec.add_dependency "grocer", '~> 0.7.0'
  spec.add_dependency "connection_pool", '~> 2.0.0'
 
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-rcov"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency 'byebug'
  
end
