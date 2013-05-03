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

Capistrano::Configuration.instance.load do

  load 'deploy/assets'

  set :stages, %w(production staging development)
  set :default_stage, "staging"

  set :scm, :mercurial
  set :branch, fetch(:branch, "tip")

  set :user, "deploy"
  set :use_sudo, false
  set :web_server, :passenger

  set (:full_app_domain) { "#{app_sub_domain}.#{parent_domain}" }

  set (:deploy_to) { "/var/www/#{app_sub_domain}" } #otherwise override by app_sub_domain does not work

  set (:keep_releases) { fetch(:keep_releases, 3) }

  # Backup location for old utils backup
  set :backup_to, "/home/#{user}/backups_deploy/#{application}"


  #############################################################
  # Default hooks
  #############################################################

  before "deploy", "deploy:web:disable"
  after "deploy", "deploy:web:enable"

  after "deploy:assets:symlink", "deploy:symlink_db_config"

  after "deploy:restart", "deploy:cleanup"
  after "deploy:web:enable" , "deploy:preload_app"
end
