Capistrano::Configuration.instance.load do

  namespace :passenger do

    desc "|CustomRecipes| Inspect Phusion Passenger's memory usage."
    task :memory, :roles => :app do
      run "#{try_sudo} passenger-memory-stats"
    end

    desc "|CustomRecipes| Inspect Phusion Passenger's internal status."
    task :status, :roles => :app do
      run "#{try_sudo} passenger-status"
    end
  end


  #TODO only do this if passenger variable is set
  # If you are using Passenger mod_rails uncomment this:
  namespace :deploy do
    task :restart do
      run "#{try_sudo} mkdir -p #{File.join(current_path, 'tmp')}"
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end

end