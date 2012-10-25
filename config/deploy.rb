require "mina/bundler"
require "mina/rails"
require "mina/git"

set :domain, "rumney"
set :deploy_to, "/srv/www/arvnd.com"
set :repository, "git://github.com/arvindx007/arvnd.git"
set :branch, "master"

set :shared_paths, ["log", "tmp/pids", "tmp/sockets"]

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      if ENV["cold"]
        invoke :start
      else
        invoke :restart
      end
    end
  end
end

task :start do
  invoke :'unicorn:start'
end

task :restart do
  invoke :'unicorn:restart'
end

task :stop do
  invoke :'unicorn:stop'
end

namespace :unicorn do
  task :start => :environment do
    queue "cd #{deploy_to}/#{current_path}"
    queue "SHARED_PATH=#{deploy_to}/shared UNICORN_PWD=#{deploy_to}/#{current_path} bin/unicorn -c config/unicorn.rb -E #{rails_env} -D"
  end

  task :restart do
    queue "kill -s HUP `cat #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  end

  task :stop do
    queue "kill -s QUIT `cat #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  end
end