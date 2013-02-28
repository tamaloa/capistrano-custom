# =========================================================================
# These are helper methods that will be available to your recipes.
# =========================================================================


def environment
  if exists?(:stage)
    stage
  else
    # We do not want to run into production by mistake
    "staging"
  end
end

def run_rake(cmd, options={}, &block)
  command = "cd #{release_path} && /usr/bin/env bundle exec rake #{cmd} RAILS_ENV=#{environment}"
  run(command, options, &block)
end

#def run_rails_command(cmd, options={}, &block)
#  command = "cd #{deploy_to}/current && /usr/bin/env bundle exec rails runner '#{cmd}' RAILS_ENV=#{rails_env}"
#  run(command, options, &block)
#end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

# Path to where the generators live
def templates_path
  expanded_path_for('../generators')
end

def docs_path
  expanded_path_for('../doc')
end

def expanded_path_for(path)
  e = File.join(File.dirname(__FILE__),path)
  File.expand_path(e)
end

def parse_config(file)
  require 'erb'  #render not available in Capistrano 2
  template=File.read(file)          # read it
  return ERB.new(template).result(binding)   # parse it
end

# =========================================================================
# Prompts the user for a message to agree/decline
# =========================================================================
def ask(message, default=true)
  Capistrano::CLI.ui.agree(message)
end

# Generates a configuration file parsing through ERB
# Fetches local file and uploads it to remote_file
# Make sure your user has the right permissions.
def generate_config(local_file,remote_file)
  temp_file = '/tmp/' + File.basename(local_file)
  buffer    = parse_config(local_file)
  File.open(temp_file, 'w+') { |f| f << buffer }
  upload temp_file, remote_file, :via => :scp
  `rm #{temp_file}`
end 

# =========================================================================
# Executes a basic rake task. 
# Example: run_rake log:clear
# =========================================================================
def run_rake(task)
  run "cd #{release_path} && rake #{task} RAILS_ENV=#{environment}"
end