# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'people-production'
set :repo_url, 'git@github.com:Spin42/people.git'
set :branch, ENV["branch"] || 'master'

set :deploy_to, '/home/people-production'

set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.0.0-p353@people-production'

set :linked_files, %w{.env}
set :linked_dirs, %w{bin log tmp/pids}

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "kill -s TERM `cat #{shared_path}/tmp/pids/unicorn.pid`"
      execute "cd #{release_path} && ~/.rvm/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec unicorn -c #{current_path}/config/unicorn/#{fetch(:stage)}.rb -E #{fetch(:stage)} -D"
    end
  end

  task :start do
    on roles(:app) do
      execute "cd #{release_path} && ~/.rvm/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec unicorn -c #{current_path}/config/unicorn/#{fetch(:stage)}.rb -E #{fetch(:stage)} -D"
    end
  end

  task :stop do
    on roles(:app) do
      execute "kill -s TERM `cat #{shared_path}/tmp/pids/unicorn.pid`"
    end
  end

  after :publishing, :restart

end