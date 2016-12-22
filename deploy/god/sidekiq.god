 rails_env = ENV['RAILS_ENV'] || "production"
 rails_root = ENV['RAILS_ROOT'] || "/var/top50sweb/current"

 God.watch do |w|

   w.name = "sidekiq"
   w.interval = 30.seconds
   w.start = "cd #{ENV['RAILS_ROOT']}; sidekiq -C /srv/books/current/config/sidekiq.yml"
   w.stop = "cd #{ENV['RAILS_ROOT']}; exec sidekiqctl stop /srv/books/shared/tmp/pids/sidekiq.pid"
   w.restart = "#{w.stop} && #{w.start}"
   w.start_grace = 10.seconds
   w.restart_grace = 10.seconds
   w.log = File.join(ENV['RAILS_ROOT'], 'log', 'sidekiq.log')

   # determine the state on startup
   w.transition(:init, {true => :up, false => :start}) do |on|
     on.condition(:process_running) do |c|
       c.running = true
     end
   end

   # determine when process has finished starting
   w.transition([:start, :restart], :up) do |on|
     on.condition(:process_running) do |c|
       c.running = true
       c.interval = 5.seconds
     end

     # failsafe
     on.condition(:tries) do |c|
       c.times = 5
       c.transition = :start
       c.interval = 5.seconds
     end
   end

   # start if process is not running
   w.transition(:up, :start) do |on|
     on.condition(:process_running) do |c|
       c.running = false
     end
   end


   # Notifications
   # --------------------------------------
   w.transition(:up, :start) do |on|
     on.condition(:process_exits) do |p|
       p.notify = 'ect'
     end
   end


 end