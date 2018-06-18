source 'https://rubygems.org'

ruby '2.3.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Specify your gem's dependencies in notifiable-apns-grocer.gemspec
gemspec

gem 'grocer', github: 'FutureWorkshops/grocer', ref: 'd574d5adca5d800eee2fac47f4ba64ce9a2d4a93'