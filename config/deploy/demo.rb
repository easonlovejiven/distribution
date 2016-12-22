set :stage, :demo

server "beta.yuukuo.com", user: "root", roles: %w{web app db}
# server "server2.example.com", user: "deploy_user", roles: %w{web app}

set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
set :database_path, "deploy/"
set :deploy_user, 'root'
set :use_sudo, true
