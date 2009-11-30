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

role :app, "adenin.ru"
role :web, "adenin.ru"
role :db,  "adenin.ru" , :primary => true

set :spinner, false
set :deploy_via, :remote_cache

set(:shared_database_path) {"#{shared_path}/databases"}


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
    run "/opt/nginx2/sbin/nginx -c #{current_path}/config/nginx/production.conf"
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

namespace :sqlite3 do
  desc "Generate a database configuration file"
  task :build_configuration, :roles => :db do
    db_options = {
      "adapter"  => "sqlite3",
      "database" => "#{shared_database_path}/production.sqlite3"
    }
    config_options = {"production" => db_options}.to_yaml
    put config_options, "#{shared_config_path}/sqlite_config.yml"
  end
 
  desc "Links the configuration file"
  task :link_configuration_file, :roles => :db do
    run "ln -nsf #{shared_config_path}/sqlite_config.yml #{release_path}/config/database.yml"
  end
 
  desc "Make a shared database folder"
  task :make_shared_folder, :roles => :db do
    run "mkdir -p #{shared_database_path}"
  end
end


# after "deploy:start", "delayed_job:start" 
# after "deploy:stop", "delayed_job:stop" 
# after "deploy:restart", "delayed_job:restart" 

after "deploy:setup", "sqlite3:make_shared_folder"
after "deploy:setup", "sqlite3:build_configuration"
 
before "deploy:migrate", "sqlite3:link_configuration_file"
