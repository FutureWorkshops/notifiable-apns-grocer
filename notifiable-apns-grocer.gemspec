# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'notifiable/apns/grocer/version'

Gem::Specification.new do |spec|
  spec.name          = "notifiable-apns-grocer"
  spec.version       = Notifiable::Apns::Grocer::VERSION
  spec.authors       = ["Matt Brooke-Smith"]
  spec.email         = ["matt@futureworkshops.com"]
  spec.homepage      = "http://www.futureworkshops.com"
  spec.description   = "Notifiable APNS plugin for Grocer"
  spec.summary       = "Notifiable APNS plugin for Grocer"
  spec.license       = "Apache 2.0"

  spec.files         = Dir['{lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency "notifiable-core", ">= 0.1.3"
  spec.add_dependency "grocer", '~> 0.7.2'
  spec.add_dependency "connection_pool", '~> 2.0.0'
 
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-rcov"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "pg"
  
end
