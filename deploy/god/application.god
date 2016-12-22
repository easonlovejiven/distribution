rails_env = ENV['RAILS_ENV'] || "production"
rails_root = ENV['RAILS_ROOT'] || "/var/www/weimall/current"
God.watch do |w|
  w.dir = "#{rails_root}"
  w.name = "sync_sell_data"
  w.interval = 10.seconds
  w.pid_file = "#{rails_root}/tmp/pids/#{w.name}.pid"
  w.env = {"RAILS_ENV"=>"#{rails_env}", 'PIDFILE' => w.pid_file}
  #w.log = "#{rails_root}/log/production.log"
  w.start = "bundle exec rake shop:product:sync_sell_data_periodical"
end

God.watch do |w|
  w.dir = "#{rails_root}"
  w.name = "sync_sell_data_periodical"
  w.interval = 10.seconds
  w.pid_file = "#{rails_root}/tmp/pids/#{w.name}.pid"
  w.env = {"RAILS_ENV"=>"#{rails_env}", 'PIDFILE' => w.pid_file}
  #w.log = "#{rails_root}/log/production.log"
  w.start = "bundle exec rake shop:trade:try_punish_periodical"
end
