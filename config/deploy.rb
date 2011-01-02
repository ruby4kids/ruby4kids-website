set :domain, 'ruby4kids.com'
server 'ruby4kids.com', :web, :app, :db, :primary => true

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2-p0@ruby4kids'
set :rvm_type,        :system_wide

require 'bundler/capistrano'

set :application,           'ruby4kids'
set :scm,                   :git
set :repository,            'git@github.com:ruby4kids/ruby4kids-website.git'
set :branch,                'origin/master'
set(:deploy_to)             { "/home/ruby4kids/deploy" }
set :user,                  'ruby4kids'
set :group,                 'ruby4kids'
set :use_sudo,              false
set :shared_children,       %w(config db db/sphinx log pids private system)

set :cleanup_targets,       %w(log public/system tmp/pids)
set :release_directories,   %w(config/private log tmp)

set(:release_symlinks) do
  {
  }
end

set(:shared_symlinks) do
  {
    'config/database.yml'    => 'config/database.yml',
    'config/sphinx.yml'      => 'config/sphinx.yml',
    'config/application.yml' => 'config/application.yml',
    'db/sphinx'              => 'db/sphinx',
    'log'                    => 'log',
    'pids'                   => 'tmp/pids',
    'system'                 => 'public/system'
  }
end

def run_remote(cmd)
  run "cd #{current_path} && #{cmd}"
end

def run_remote_rake(task)
  rails_env = fetch(:rails_env, 'integration')
  run_remote("rake #{task} RAILS_ENV=#{rails_env}")
end

def bundle_exec(cmd)
  run_remote("bundle exec #{cmd}")
end

after  'deploy:setup',       'bundle:install'

before 'deploy:symlink',     'bundle:install'
after  'deploy:symlink',     'deploy:web:disable'

after  'deploy:restart',     'deploy:web:enable'

namespace :deploy do

  desc "Deploy the current stage"
  task :default do
    update
    restart
  end

  desc "Deploy the current stage and any pending migrations"
  task :migrations do
    update
    db.migrate
    restart
  end

  desc "Set up the current stage for Git-based deployment"
  task :setup, :except => { :no_release => true } do
    setup_command = ["rm -fr #{current_path}"]
    setup_command << "git clone #{repository} #{current_path}"
    setup_command << shared_children.map { |dir| "mkdir -p #{shared_path}/#{dir} && chmod g+w #{shared_path}/#{dir}" }
    run setup_command.join(' && ')
  end

  desc "Update the current stage to the latest revision"
  task :update_code, :except => { :no_release => true } do
    update_command = ["git fetch origin && git reset --hard #{branch}"]
    update_command << "echo #{branch} > #{current_path}/BRANCH"
    update_command << "git rev-parse --verify HEAD --short > #{current_path}/REVISION"
    run "cd #{current_path} && #{update_command.join(' && ')}"
  end

  namespace :rollback do
    task :default do
      code
    end

    task :code, :except => { :no_release => true } do
      set :branch, 'HEAD^'
      deploy
    end
  end

end
