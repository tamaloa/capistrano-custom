# Capistrano::Custom

Custom capistrano tasks and defaults.
Highly opinionated set of capistrano recipes.
For systems built on mysql, apache + passenger, ubuntu (although it should be adaptable for others).
This gem allows to easily deploy to a production and a staging server and additionally
to three predefined dev domains. It requires multistage extension

## Installation

Start by capifying your application and adding the default templates from this gem

    $ capify .
    $ gem install capistrano-custom #If you not had it installed before
    $ rake capistrano:custom:templates:install #TODO implement a raketask similar to this one

The templates are copied to your config dir and contain a deploy.rb and inside the deploy dir a setting file for each stage.
Look through all of these files to fill in your servers, repositories etc.

## Usage

There are three deploy environments: production, staging and development. Production and staging each run on their own
application specific subdomain. The development environments are p1, p2, p3 and these three subdomains may be shared by several applications (more below).

Following assumptions are made:

* The apps are rolled out to a ubuntu system running apache passenger and a mysql database.
* Small apps thus one server to rule an app (no seperate db, web etc for now)
* webapps are contained in /var/www/app-sub-domain
* deployment user (of course for production there should be app specific ones) is passenger, sudo is not used.
* mercurial repository
* and everything else set in lib/capistrano-custom/defaults.rb

On rollouts the database.yml is symlinked between versions. The maintenance state is indicated
by app/public/system/maintenance.txt (see template apache for appropriate config).
After rollout passenger is restarted and old deploys cleaned up.
Also the app is preloaded by wgetting the apps root page.

### Initial setup /cold deploy

To create the directory structure and a shared database.yml (db user, pwd, name are asked for on the console)

    $ cap <stage> deploy:setup

To make an initial checkout and db:setup

    $ cap <stage> deploy:cold #TODO this working for development stages but was not implemented for the others


### Deploying to staging system

The default is to deploy to the staging system. I recommend to simply use

    $ cap deploy:migrations

to deploy to stage and run all pending migrations. This is equal to indicating staging as stage:

    $ cap staging deploy:migrations

### Deploy to production

For production it is recommended to use the provided backup tasks to backup the database and necessary files.
TODO use app specific file backup instructions
TODO switch to enhanced mysql:db:dump/restore scripts

    $ cap production deploy:migrations

If it is required to rollout a specific branch this can be indicated by

    $ cap production deploy:migrations -S branch=releaseX-bugfixes

specifying the branch to rollout is possible on any of the environments.


### Deploy to dev

There are three dev domains preset. These are supposed to be used by individual developers to check their own work.
If deploy:migrations is used the database is cleaned and recreated by db:setup on every rollout.
Also all fixtures are loaded via db:fixtures:load.
Thus any of the three dev domains may be used by any application.

For example a developer on of app_one may rollout his latest changes to p1 via

    ~/app_one$ cap development deploy:migrations -S app_sub_domain=p1

Then a second developer can roll out his changes to a topic branch on app_foo via

    ~/app_foo$ cap development deploy:migrations -S app_sub_domain=p1 branch=app_foo



## Inspired by

Gem structure for custom capistrano recipes and setting defaults is nicely explained by
[timriley](http://openmonkey.com/blog/2010/01/19/making-your-capistrano-recipe-book/)

Some recipes adopted from [webficient](https://github.com/webficient/capistrano-recipes)

maintenance page setup taken from [capistrano-maintenance gem](https://github.com/tvdeyen/capistrano-maintenance)
(added support for app specific maintenance template)