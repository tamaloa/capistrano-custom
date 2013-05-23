Capistrano::Configuration.instance.load do

  namespace :deploy do

    task :restart, :roles => :app, :except => {:no_release => true} do
      run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    end

    task :preload_app, :roles => :web, :except => {:no_release => true} do
      run "#{try_sudo} wget #{full_app_domain} -O /dev/null &> /dev/null"
    end

    desc "Make symlink for database yaml"
    task :symlink_db_config do
      set(:release_db_yml) { File.join(release_path, 'config', 'database.yml') }
      set(:shared_db_yml) { File.join(shared_path, 'config', 'database.yml') }
      run "#{try_sudo} rm -f #{release_db_yml}}" #just in case a database.yml is checked in
      run "#{try_sudo} ln -nfs #{shared_db_yml} #{release_db_yml}"
    end

    desc "Make symlink for application yaml"
    task :symlink_app_config do
      set(:release_app_yml) { File.join(release_path, 'config', 'application.yml') }
      set(:shared_app_yml) { File.join(shared_path, 'config', 'application.yml') }
      run "#{try_sudo} rm -f #{release_app_yml}}" #just in case a database.yml is checked in
      run "#{try_sudo} ln -nfs #{shared_app_yml} #{release_app_yml}"
    end

    namespace :web do
      set (:maintenance_page) { File.join(shared_path, 'system', 'maintenance.html') }
      task :disable, :roles => :web, :except => {:no_release => true} do
        require 'erb'
        on_rollback { run "#{try_sudo} rm -f #{maintenance_page}" }


        # Decide to use app specific maintenance page or template
        gem_maintenance_template = File.join(File.expand_path('..', File.dirname(__FILE__)) , "templates", "maintenance.html.erb")
        remote_maintenance_template = File.join(current_path, 'public', 'maintenance.html')

        if remote_file_exists?(remote_maintenance_template)
          #TODO also use ENV variables to customize remote page
          run "#{try_sudo} cp #{remote_maintenance_template} #{maintenance_page}"
        else
          reason = ENV['REASON']
          deadline = ENV['UNTIL']

          template = File.read(gem_maintenance_template)
          result = ERB.new(template).result(binding)

          put result, maintenance_page, :mode => 0644
        end

      end
      task :enable, :roles => :web do
        run "#{try_sudo} rm -f #{maintenance_page}"
      end
    end

  end

end