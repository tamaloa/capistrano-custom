server "production-server-name", :app, :web, :db, :primary => true

set :rails_env, "production"
set :keep_releases, 5