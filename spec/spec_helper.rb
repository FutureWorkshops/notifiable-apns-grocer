ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  minimum_coverage 80
  add_filter "/spec/"
  add_filter "/db/"
end

require 'active_record'
require 'rails'
require 'notifiable'
require 'grocer'
require File.expand_path("../../lib/notifiable/apns/grocer",  __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|  
  config.mock_with :rspec
  config.order = "random"
  
  config.before(:all) {
    
    # DB setup
    ActiveRecord::Base.establish_connection(
     { :adapter => 'sqlite3',
       :database => 'db/test.sqlite3',
       :pool => 5,
       :timeout => 5000}
    )
    
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate "db/migrate"
    
    @grocer = Grocer.server(port: 2195)
    @grocer.accept
    
    Notifiable.apns_gateway = "localhost"
  }
  
  config.before(:each) {
    @grocer.notifications.clear
  }
  
  config.after(:all) {
    @grocer.close
    
    # drop the database
    File.delete('db/test.sqlite3')
  }
end
