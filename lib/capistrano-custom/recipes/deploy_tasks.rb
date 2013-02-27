Capistrano::Configuration.instance.load do

  namespace :deploy do

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   task :preload_app, :roles => :web, :except => { :no_release => true } do
     run "#{try_sudo} wget #{app_domain}.ci.moez.fraunhofer.de -O /dev/null &> /dev/null"
   end

   desc "Make symlink for database yaml"
   task :symlink_db_config do
     set(:release_db_yml) { File.join(release_path,'config','database.yml') }
     set(:shared_db_yml) { File.join(shared_path,'config','database.yml') }
     run "#{try_sudo} rm -f #{release_db_yml}}" #just in case a database.yml is checked in
     run "#{try_sudo} ln -nfs #{shared_db_yml} #{release_db_yml}"
   end


   namespace :web do
     set (:maintenance_indicator_file) {File.join(shared_path,'system','maintenance.txt')}
       task :disable, :roles => :web do
         on_rollback { run "#{try_sudo} rm #{maintenance_indicator_file}" }

         run "#{try_sudo} touch #{maintenance_indicator_file}"
       end
       task :enable, :roles => :web do
         run "#{try_sudo} rm -f #{maintenance_indicator_file}"
       end
     end
  end

end