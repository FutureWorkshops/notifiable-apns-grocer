ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "/spec/"
end

require 'timeout'
require 'database_cleaner'
require 'active_record'
require 'rails'
require 'notifiable'
require 'grocer'
require File.expand_path("../../lib/notifiable/apns/grocer",  __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

db_path = 'spec/test.sqlite3'
DatabaseCleaner.strategy = :truncation

Rails.logger = Logger.new(STDOUT)

require 'byebug'

RSpec.configure do |config|  
  config.mock_with :rspec
  config.order = "random"
  
  config.before(:all) {
    Notifiable.notifier_classes[:apns] = Notifiable::Apns::Grocer::Stream
    Notifiable::App.define_configuration_accessors(Notifiable.notifier_classes)
    
    # DB setup
    ActiveRecord::Base.establish_connection(
     { :adapter => 'sqlite3',
       :database => db_path,
       :pool => 5,
       :timeout => 5000}
    )
    
    ActiveRecord::Migration.verbose = false
    notifiable_rails_path = Gem.loaded_specs['notifiable-rails'].full_gem_path
    ActiveRecord::Migrator.migrate File.join(notifiable_rails_path, 'db', 'migrate')
    
    @grocer = Grocer.server(port: 2195)
    @grocer.accept
  }
  
  config.before(:each) {
    DatabaseCleaner.start
    @grocer.notifications.clear
  }
  
  config.after(:each) {
    DatabaseCleaner.clean
  }
  
  config.after(:all) {
    @grocer.close
    
    # drop the database
    File.delete(db_path)
  }
end
