#How to configure TeamCity to rollout application to staging environment

# 1. make sure teamcity-agent can ssh into staging machine (basically try to do a deploy from the agent)
# 2. setup teamcity build
# 3. Under "Version Control Settings" for "VCS checkout mode" select "Automatically on Agent"
#     otherwise the .hg/.git dir is not available and capistrano needs to retrieve information such as revision
# 4. As steps you only need the usual bundle install (or make sure capistrano is available)
# 5. deploystep: cap deploy as on the dev system