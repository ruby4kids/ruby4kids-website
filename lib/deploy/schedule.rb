namespace :deploy do
  namespace :schedule do

    task :default do
      update
    end

    desc "Update the crontab for the current stage"
    task :update, :roles => :app do
      bundle_exec "whenever --update-crontab #{application}-#{stage}"
    end

  end
end
