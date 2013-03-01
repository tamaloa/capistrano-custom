############################################
# Set all main information here and
# override defaults set by capistrano-custom
############################################

set :application, "app-name"
set :repository,  "applications mercurial repository (http://code.yourserver/app-name"
set :parent_domain, "your.domain"

# Following variables should be set in the corresponding environment
#server "your.stage.server.name", :app, :web, :db, :primary => true
#set :app_sub_domain, "stage-app_name"
#set :rails_env, "staging"
#set :keep_releases, 2


# We only load our custom recipes after specifying the main variables above
require 'capistrano-custom/recipes'
require 'capistrano-custom/defaults'


# The following tasks are more specific and should only be used if necessary

# Setup cron jobs
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

#Notify airbrake of deploy
require './config/boot'
require 'airbrake/capistrano'