require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'capistrano_colors'

load 'deploy/assets'

load 'config/deploy/recipes/helpers'
load 'config/deploy/recipes/db'
load 'config/deploy/recipes/deploy_tasks'
load 'config/deploy/recipes/passenger'
