# # Uncomment if you are using Rails' asset pipeline
#     # load 'deploy/assets'

# $LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')

require "capistrano/setup"
require "capistrano/deploy"


require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/rvm'
require 'capistrano/rails/console'
require 'capistrano/sidekiq'
require 'capistrano-db-tasks'


# import 'deploy/config/deploy.rb' # remove this line to skip loading any of the default tasks
Dir.glob("deploy/tasks/*.cap").each { |r| import r }
