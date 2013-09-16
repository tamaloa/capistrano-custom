require 'erb'

Capistrano::Configuration.instance.load do

  namespace :db do

    namespace :mysql do
      desc <<-EOF
      |CustomRecipes| Performs a compressed database dump. \
      WARNING: This locks your tables for the duration of the mysqldump.
      Don't run it madly!
      EOF
      task :dump, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "#{try_sudo} mkdir -p #{current_path}/backup"
        run "mysqldump --user=#{db_user} -p --host=#{db_host} #{db_name} | bzip2 -z9 > #{db_remote_file}" do |ch, stream, out|
        ch.send_data "#{db_pass}\n" if out =~ /^Enter password:/
          puts out
        end
      end

      desc "|CustomRecipes| Restores the database from the latest compressed dump"
      task :restore, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "bzcat #{db_remote_file} | mysql --user=#{db_user} -p --host=#{db_host} #{db_name}" do |ch, stream, out|
        ch.send_data "#{db_pass}\n" if out =~ /^Enter password:/
          puts out
        end
      end

      desc "|CustomRecipes| Create MySQL database and user for this environment using prompted values"
      task :setup, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        prepare_for_db_command

        #TODO add creation of user

        sql = <<-SQL
               CREATE DATABASE IF NOT EXISTS #{db_name};
               GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY '#{db_pass}';
               SQL

        run "mysql --user=#{db_admin_user} -p --execute=\"#{sql}\"" do |channel, stream, data|
          if data =~ /^Enter password:/
            pass = Capistrano::CLI.password_prompt "Enter database password for '#{db_admin_user}':"
            channel.send_data "#{pass}\n" 
          end
        end
      end

    end


    namespace :postgres do
      desc "|CustomRecipes| Performs a compressed database dump."
      task :dump, :roles => :db, :only => {:primary => true} do
        prepare_from_yaml
        run "#{try_sudo} mkdir -p #{current_path}/backup"
        run "pg_dump #{db_name} --clean --no-owner | bzip2 -z9 > #{db_remote_file}"
      end

      desc "|CustomRecipes| Restores the database from the latest compressed dump"
      task :restore, :roles => :db, :only => {:primary => true} do
        prepare_from_yaml
        run "bzcat #{db_remote_file} | psql #{db_name}"
      end

    end


    desc "|CustomRecipes| Create database.yml in shared path with settings for current stage and test env"
    task :create_yaml do

      set(:db_name) { Capistrano::CLI.ui.ask "Enter #{environment} database name:" }
      set(:db_user) { Capistrano::CLI.ui.ask "Enter #{environment} database username:" }
      set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{environment} database password:" }

      #TODO: load database.example.yml and use it as config example?
      db_config = ERB.new <<-EOF
      base: &base
        adapter: mysql2
        encoding: utf8
        username: #{db_user}
        password: #{db_pass}

      #{environment}:
        database: #{db_name}
        <<: *base
      EOF

      run "#{try_sudo} mkdir -p #{shared_path}/config"
      put db_config.result, "#{shared_path}/config/database.yml"
    end

    desc "Populates the database with seed data"
    task :seed do
      Capistrano::CLI.ui.say "Populating the database..."
      run_rake("db:seed")
    end

    desc "Populates the database with seed data"
    task :setup do
      Capistrano::CLI.ui.say "Creating and setting up the database..."
      run_rake("db:setup")
    end

    desc "Populates the database with fixtures data"
    task :create_and_load_fixtures do
      exit if environment.eql?('production')
      Capistrano::CLI.ui.say "Dropping old database and prepopulating with fixtures"
      run_rake("db:drop")
      run_rake("db:setup")
      run_rake("db:fixtures:load")
    end


    desc "|CustomRecipes| Downloads the compressed database dump to this machine"
    task :fetch_dump, :roles => :db, :only => { :primary => true } do
      prepare_from_yaml
      download db_remote_file, db_local_file, :via => :scp
    end

  end
    
  def prepare_for_db_command
    #set :db_name, "#{application}_#{environment}"
    set(:db_admin_user) { Capistrano::CLI.ui.ask "Username with priviledged database access (to create db):" }
    #set(:db_user) { Capistrano::CLI.ui.ask "Enter #{environment} database username:" }
    #set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{environment} database password:" }
  end

        # Sets database variables from remote database.yaml
      def prepare_from_yaml
        set(:db_file) { "#{application}-dump.sql.bz2" }
        set(:db_remote_file) { "#{current_path}/backup/#{db_file}" }
        set(:db_local_file) { "tmp/#{db_file}" }
        set(:db_user) { db_config[rails_env]["username"] }
        set(:db_pass) { db_config[rails_env]["password"] }
        set(:db_host) { db_config[rails_env]["host"] }
        set(:db_name) { db_config[rails_env]["database"] }
      end

      def db_config
        @db_config ||= fetch_db_config
      end

      def fetch_db_config
        require 'yaml'
        file = capture "cat #{shared_path}/config/database.yml"
        db_config = YAML.load(file)
      end

  
  after "deploy:setup" do
    db.create_yaml if Capistrano::CLI.ui.agree("Create database.yml in app's shared path? [Yn]")
  end

end
