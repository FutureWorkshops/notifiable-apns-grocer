require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "/spec/"
end

require 'timeout'
require 'database_cleaner'
require 'active_record'
require 'notifiable'
require 'notifiable/apns/grocer'
require 'grocer'
require 'byebug'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Setup ActiveRecord db connection
ActiveRecord::Base.establish_connection(YAML.load_file('config/database.yml')['test'])

RSpec.configure do |config|  
  config.mock_with :rspec
  config.order = "random"
  
  config.before(:all) {
    DatabaseCleaner.strategy = :truncation
    Notifiable.notifier_classes[:apns] = Notifiable::Apns::Grocer::Stream
    Notifiable::App.define_configuration_accessors(Notifiable.notifier_classes)
        
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
  }
end
