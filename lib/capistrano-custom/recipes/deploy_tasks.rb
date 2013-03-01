Capistrano::Configuration.instance.load do

  namespace :deploy do

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   task :preload_app, :roles => :web, :except => { :no_release => true } do
     run "#{try_sudo} wget #{full_app_domain} -O /dev/null &> /dev/null"
   end

   desc "Make symlink for database yaml"
   task :symlink_db_config do
     set(:release_db_yml) { File.join(release_path,'config','database.yml') }
     set(:shared_db_yml) { File.join(shared_path,'config','database.yml') }
     run "#{try_sudo} rm -f #{release_db_yml}}" #just in case a database.yml is checked in
     run "#{try_sudo} ln -nfs #{shared_db_yml} #{release_db_yml}"
   end


   namespace :web do
     set (:maintenance_page) {File.join(shared_path,'system','maintenance.html')}
       task :disable, :roles => :web do
         on_rollback { run "#{try_sudo} rm #{maintenance_page}" }

         maintenance_template = File.join(current_path, 'public', 'maintenance.html')

         if remote_file_exists?(maintenance_template)
           # We use the existing maintenance page
           run "#{try_sudo} cp #{maintenance_template} #{maintenance_page}"
         else
           #TODO create default file!
           run "#{try_sudo} touch #{maintenance_page}"
         end

       end
       task :enable, :roles => :web do
         run "#{try_sudo} rm -f #{maintenance_page}"
       end
     end
  end

end