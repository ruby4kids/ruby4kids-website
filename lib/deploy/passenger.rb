namespace :deploy do

  desc "No-op"
  task :start, :roles => :app, :except => { :no_release => true } do
  end

  desc "No-op"
  task :stop, :roles => :app, :except => { :no_release => true } do
  end

  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

end
