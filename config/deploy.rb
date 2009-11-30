default_run_options[:pty] = true

set :application, "changer"

set :scm, :git
set :repository,  "git@github.com:pronix/changer.git"
set :ssh_options, {:forward_agent => true}
set :branch, "master"

set :user, "root"

set :deploy_via, :remote_cache
set :deploy_to, "/home/#{application}"
set :use_sudo, false

role :app, "hadoop.adenin.ru"
role :web, "hadoop.adenin.ru"
role :db,  "hadoop.adenin.ru" , :primary => true

set :spinner, false
set :deploy_via, :remote_cache

namespace :delayed_job do
  desc "Start delayed_job process" 
  task :start, :roles => :app do
    run "cd #{current_path}; script/delayed_job start #{rails_env}" 
  end

  desc "Stop delayed_job process" 
  task :stop, :roles => :app do
    run "cd #{current_path}; script/delayed_job stop #{rails_env}" 
  end

  desc "Restart delayed_job process" 
  task :restart, :roles => :app do
    run "cd #{current_path}; script/delayed_job restart #{rails_env}" 
  end
end

namespace :deploy do
    desc "Restarting passenger with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
        run "touch #{current_path}/tmp/restart.txt"
    end
      
    [:start, :stop].each do |t|
        desc "#{t} task is a no-op with passenger"
        task t, :roles => :app do ; end
    end
end

namespace :nginx do 
  
  desc "start"
  task :start, :roles => :web do 
    run "/opt/nginx/sbin/nginx -c #{current_path}/config/nginx/production.conf"
  end
  
  desc "stop"
  task :stop, :roles => :web do 
    run "kill -s QUIT `cat #{shared_path}/log/nginx.pid`"
  end
  
  desc "reload config"
  task :reload_config, :roles => :web do 
    run "kill -s HUP `cat #{shared_path}/log/nginx.pid`"
  end
  
  desc "reopen log"
  task :reopen_logs, :roles => :web do 
    run "kill -s USR1 `cat #{shared_path}/log/nginx.pid`"
  end
 
  desc "restart"
  task :restart, :roles => :web do 
    reload_config
    reopen_log
  end
  
end

# after "deploy:start", "delayed_job:start" 
# after "deploy:stop", "delayed_job:stop" 
# after "deploy:restart", "delayed_job:restart" 
