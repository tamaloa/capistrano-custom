# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-custom/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-custom"
  gem.version       = Capistrano::Custom::VERSION
  gem.authors       = ["Michael Prilop"]
  gem.email         = ["Michael.Prilop@gmail.com"]
  gem.description   = %q{Custom capistrano tasks and defaults. Highly opinionated set of capistrano recipes.
                        For systems built on mysql, apache + passenger, ubuntu (although it should be adaptable for others).
                        This gem allows to easily deploy to a production and a staging server and additionally
                        to three predefined dev domains. It requires multistage extension }
  gem.summary       = %q{Custom capistrano tasks and defaults}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'capistrano', "~> 2"
  gem.add_runtime_dependency 'capistrano_colors'

end
