default_run_options[:pty] = true

set :application, "changer"

set :scm, :git
set :repository,  "git@github.com:pronix/changer.git"
set :ssh_options, {:forward_agent => true}
set :branch, "master"

set :user, "root"

set :deploy_via, :remote_cache
set :deploy_to, "/home/#{application}"
set :use_sudo, true

role :app, "hadoop.adenin.ru"
role :web, "hadoop.adenin.ru"
role :db,  "hadoop.adenin.ru" , :primary => true

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


# after "deploy:start", "delayed_job:start" 
# after "deploy:stop", "delayed_job:stop" 
# after "deploy:restart", "delayed_job:restart" 
