require "bundler/gem_tasks"
require 'rspec/core/rake_task'
Dir[File.join(File.dirname(__FILE__), 'lib/tasks/**/*.rake')].each {|f| load f }

namespace :ci do
  namespace :test do
    desc "Run all specs in spec directory (excluding plugin specs)"
    RSpec::Core::RakeTask.new(:spec)
  end
  
  task :prepare
  
  desc "Run all CI tests"
  task :test => ['ci:test:spec']
end