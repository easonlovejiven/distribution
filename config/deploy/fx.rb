set :stage, :fx

server "120.132.51.168", user: "hong", roles: %w{web app db}
# server "server2.example.com", user: "deploy_user", roles: %w{web app}

set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
# set :git_repo_url, "git@git.oschina.net:myjacksun/weimall.git"
set :deploy_user, 'hong'
set :use_sudo, false