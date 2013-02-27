##########################################################
# For setting up on a new system use
# cap deploy:setup
# -> will also give possibility to create new database.yml
##########################################################
##########################################################
# Here we define our defaults.
##########################################################

require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'capistrano_colors'

load 'deploy/assets'

load 'config/deploy/recipes/helpers'
load 'config/deploy/recipes/db'
load 'config/deploy/recipes/deploy_tasks'
load 'config/deploy/recipes/passenger'

set :stages, %w(production staging development)
set :default_stage, "staging"

#set :application, "application-name" is done in deploy.rb
set :scm, :mercurial


set :app_domain, fetch(:app_domain, application)

set (:deploy_to) { "/var/www/#{app_domain}" } #otherwise override by app_domain does not work

set :user, "passenger"
set :use_sudo, false
set :web_server, :passenger

# Backup location for old utils backup
set :backup_to, "/home/#{user}/backups_deploy/#{application}"


# Setting up new server

# after deploy:setup deploy:update (only get code) then bundle install then db:setup (create databases etc.) should be enough.
