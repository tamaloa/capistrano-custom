Capistrano::Configuration.instance.load do

  namespace :utils do
    namespace :backup do
      desc 'Backup database before deploy'
      task :db, :roles => :db, :only => {:primary => true} do
        run "mkdir -p #{backup_to}" # Create a backup folder unless exists

        # Primary backup filename
        filename = "#{backup_to}/#{application}_predeploy_#{Time.now.strftime("%m%d%Y%H%I%S")}.sql"

        # Check if we've got database config
        if remote_file_exists?("#{deploy_to}/current/config/database.yml")
          text = capture("cat #{deploy_to}/current/config/database.yml")
          config = YAML::load(text)[rails_env]

          on_rollback { run "rm #{filename}" }
          #with gzip
          #run "mysqldump -u #{config['username']} -p #{config['database']} | gzip --best > #{filename}" do |ch, stream, out|
          run "mysqldump -u #{config['username']} -p #{config['database']} > #{filename}" do |ch, stream, out|
            ch.send_data "#{config['password']}\n" if out =~ /^Enter password:/
          end
        else
          logger.debug("[Backup-db] No configuration file was found.")
        end
      end

      desc 'Backup files before deploy'
      task :files, :roles => :app, :only => {:primary => true} do
        run "mkdir -p #{backup_to}" # Create a backup folder unless exists

        # Primary backup filename
        filename = "#{backup_to}/#{application}_predeploy_#{Time.now.strftime("%m%d%Y%H%I%S")}.tar"

        if remote_file_exists?("#{deploy_to}/current/public/system/")
          on_rollback { run "rm #{filename}" }

          #tar all files
          run "cd #{deploy_to}/current && tar -czf #{filename} public/system/*"
        else
          logger.debug("[Backup-files] No files seem to exist.")
        end

      end

    end

  end

end