server "production-server-name", :app, :web, :db, :primary => true

set :rails_env, "production"
set :keep_releases, 5

# You propably want to do backups before production deploys
before "deploy", "utils:backup:db"
before "deploy", "utils:backup:files"
