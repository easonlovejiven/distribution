require 'thinking_sphinx/capistrano'

set :rvm_ruby_version, '2.2.0'
set :rvm_roles, [:app, :web, :db, :all]
# We use sudo (root) for system-wide RVM installation
set :rvm_install_with_sudo, false
set :rvm_install_ruby_params, "--autolibs=packages"

#==================== deploy 配置项======================
# #App Domain
# set :ssh_key, "id_rsa"
set :ssh_options, {keys: [File.join(ENV["HOME"], ".ssh", "id_rsa")], forward_agent: true}
# set :pty,true

set :application, "fx"
# Application environment
set :rails_env, :production


set :repo_url, "git@beta.yuukuo.com:fenxiao.git"
set :scm, "git"
set :scm_verbose, true
# Deploy via github
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{fetch(:application)}"
set :keep_releases, 2


# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/secrets.yml }

# dirs we want symlinking to shared
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system  public/docs db/indices}
set :bundle_binstubs, nil
set :db_remote_clean, true
set :db_local_clean, true

# Unicorn config
namespace :deploy do
  %w[start stop restart reload].each do |command|
    desc "#{command} unicorn server"
    task command do
      on roles(:all), in: :sequence, wait: 5 do
        execute "sudo /etc/init.d/unicorn_#{fetch(:application)} #{command}"
      end
    end
  end

  task :fix_permissions do
    on roles :all do
      execute "sudo mkdir -p /var/www"
      execute "sudo chown -R #{fetch(:deploy_user)}:#{fetch(:deploy_user)} /var/www"
      execute "sudo mkdir -p /var/www/#{fetch(:application)}"
      execute "sudo chown -R #{fetch(:deploy_user)}:#{fetch(:deploy_user)} /var/www/#{fetch(:application)}"
      execute "sudo chmod -R  755 /var/www/#{fetch(:application)}"
    end
  end

  before "deploy:check", "deploy:fix_permissions"

  task :setup_config do
    on roles :all do
      # add project configuration
      execute "mkdir -p #{fetch(:deploy_to)}/shared #{fetch(:deploy_to)}/shared/config #{fetch(:deploy_to)}/shared/node #{fetch(:deploy_to)}/shared/pids #{fetch(:deploy_to)}/shared/log || echo exist"
      %w{database.yml secrets.yml}.each do |file|
        sudo_upload "deploy/config/#{fetch(:stage)}/#{file}", "#{fetch(:deploy_to)}/shared/config/#{file}"
      end
      #nginx
      # execute "sudo rm -rf /usr/localnginx/config/sites-enabled/default"
      sudo_upload "deploy/config/#{fetch(:stage)}/nginx_app.conf", "/usr/local/nginx/conf/vhost/#{fetch(:application)}.conf"
      #unicorn
      sudo_upload "deploy/config/#{fetch(:stage)}/unicorn_init.sh", "/etc/init.d/unicorn_#{fetch(:application)}"
      sudo "chmod +x /etc/init.d/unicorn_#{fetch(:application)}"
    end
  end
  before :check, :"deploy:setup_config"

  desc "create database on server"
  task :create_db do
    on roles :all do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:create'
        end
      end
      # execute "mysql -u weimall -pweimall123 -e \"CREATE DATABASE IF NOT EXISTS weimall default charset utf8 COLLATE utf8_general_ci; \""
    end
  end

  task :db_seed do
    on roles :all do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:seed'
        end
      end
    end
  end


  # namespace :assets do
  task :symlink do
    execute ("rm -rf #{latest_release}/public/assets &&
            mkdir -p #{latest_release}/public &&
            mkdir -p #{shared_path}/assets &&
            ln -s #{shared_path}/assets #{latest_release}/public/assets &&
            mkdir -p #{shared_path}/uploads &&
            ln -sf #{shared_path}/uploads #{latest_release}/public/uploads
      ")
  end
  # before 'deploy:finalize_update', 'deploy:assets:symlink'

  #desc 'copy ckeditor nondigest assets'
  #task :copy_nondigest_assets do
  #  execute "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} ckeditor:copy_nondigest_assets"
  #end
  #after 'deploy:assets:precompile', 'deploy:assets:copy_nondigest_assets'

  desc "qiniu assets"
  task :qiniu_upload do
    #execute "cd #{latest_release} &&  #{rake}  RAILS_ENV=#{rails_env} assets_qiniu:upload"
    system("#{rake}  RAILS_ENV=#{rails_env} assets_qiniu:upload")
  end

  task :precompile do
    # from = source.next_revision(current_revision) #初始部署注释掉
    # if capture("cd #{shared_path}/cached-copy && git diff #{from}.. --stat | grep 'app/assets' | wc -l").to_i > 0
    run_locally("RAILS_ENV=#{rails_env}  rake assets:clobber && RAILS_ENV=#{rails_env}  rake assets:precompile")
    run_locally "cd public && tar -jcf assets.tar.bz2 assets"
    top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
    execute "cd #{shared_path} &&  rm -rf assets/*"
    execute "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
    run_locally "rm public/assets.tar.bz2"
    #execute "cd #{latest_release} && RAILS_ENV=#{rails_env}  rake assets:clean"
    # deploy.assets.qiniu_upload
    #run_locally("RAILS_ENV=#{rails_env}  rake assets:clobber")
    # else
    #   logger.info "Skipping asset precompilation because there were no asset changes"
    # end
  end

  task :precompile do
    # from = source.next_revision(current_revision) #初始部署注释掉
    # if capture("cd #{shared_path}/cached-copy && git diff #{from}.. --stat | grep 'app/assets' | wc -l").to_i > 0
    execute %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} assets:precompile}
    # else
    #   logger.info "Skipping asset precompilation because there were no asset changes"
    # end
  end
  # after 'deploy:update_code', 'deploy:assets:precompile'
  #after 'deploy:assets:precompile', 'deploy:assets:qiniu_upload'
  # end


  #=============== 配置机器环境 =======================

  task :symlink_config do
    execute "mkdir -p #{release_path}/tmp/sockets"
    # execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    # execute "ln -nfs #{shared_path}/config/node_config.json #{release_path}/node/config.json"
  end

  after :symlink, "deploy:symlink_config"


  task :update_apt_get do
    #execute "#{sudo} rm /var/lib/apt/lists/* -vf"
    #execute "#{sudo} apt-get update && #{sudo} apt-get upgrade"
    execute "#{sudo}  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A42227CB8D0DC64F"
  end

  task :set_rvm_version do
    execute "source ~/.rvm/src/rvm/scripts/rvm && rvm use #{rvm_ruby_string} --default"
  end

  after :finishing, "deploy:restart"
end


task :config do
  on roles(:all) do
    execute "sudo chmod +x /etc/init.d/mysql"
  end
end

namespace :docs do
  task :build do
    on roles(:all) do
      execute "cd  #{fetch(:deploy_to)}/current &&bash docs_build.sh"
    end
  end
end

namespace :nginx do
  %w[start stop restart].each do |cmd|
    desc "#{cmd}s nginx"
    task cmd do
      on roles(:all) do
        execute "sudo /etc/init.d/nginx #{cmd}"
      end
    end
  end

  desc "nginx install"
  task :install do
    sudo "mkdir -p /tmp/nginx"
    sudo_upload File.read("deploy/nginx/nginx_install.sh"), "/tmp/nginx/nginx_install.sh"
    sudo_upload File.read("deploy/nginx/nginx_init.sh"), "/tmp/nginx/nginx_init.sh"
    sudo_upload File.read("deploy/nginx/nginx.conf"), "/tmp/nginx/nginx.conf"
    sudo_upload File.read("deploy/nginx/default"), "/tmp/nginx/default"
    execute "cd /tmp/nginx && #{sudo} bash nginx_install.sh"
    execute "sudo /etc/init.d/nginx restart"
  end
end


namespace :coreseek do
  task :install do
    sudo "mkdir -p /tmp/sphinx"
    sudo_upload File.read('deploy/sphinx/coreseek.sh'), "/tmp/sphinx/coreseek_install.sh"
    execute " cd /tmp/sphinx && #{sudo} bash coreseek_install.sh "
  end
end

#sidekiq
set :sidekiq_cmd, "bundle exec sidekiq -C config/sidekiq.yml"
set :sidekiqctl_cmd, "bundle exec  sidekiqctl"
set :sidekiq_role, :app


# A hacky way to sudo_upload files in Capistrano with sudoer permissions
def sudo_upload(file_path, to)
  filename = File.basename(to)
  to_directory = File.dirname(to)
  execute "mkdir -p /tmp/cap_upload"
  upload! file_path, "/tmp/cap_upload/#{filename}"
  execute "sudo mv /tmp/cap_upload/#{filename} -f #{to_directory}"
end

