server "dev-server-name", :app, :web, :db, :primary => true
set :app_sub_domain, fetch(:app_sub_domain, application)

##########################################################
# We have three dev domains to choose from
##########################################################
unless exists?(:app_sub_domain) and %w{p1 p2 p3}.include?(app_sub_domain)
  p '===================================================='
  p 'call with cap deploy -S app_sub_domain=<p1 or p2 or p3> '
  p '===================================================='
  exit
end



# This could be moved to the gem soon
set :rails_env, "development"
set :keep_releases, 1
set :bundle_without, [:test] #we want the dev group but not the test group

before 'deploy:migrate', 'db:create_and_load_fixtures'

namespace :deploy do
  namespace :assets do
    task :precompile do
      p "Skipping assets:precompile because we are running development environment."
    end
  end
end