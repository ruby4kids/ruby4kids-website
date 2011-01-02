namespace :deploy do
  namespace :db do

    set(:database) { YAML.load_file("config/database.yml")[stage.to_s] }

    desc "Back up the database"
    task :backup, :roles => :db do
      on_rollback { deploy.db.rollback }

      backup_command = "#{fetch(:mysql_prefix, '')}mysqldump"
      backup_command << ' --add-drop-database'
      backup_command << ' --single-transaction'
      backup_command << " -u#{database['username']}"
      backup_command << " -p#{database['password']}" if database['password']
      backup_command << " -hlocalhost"
      backup_command << " --databases #{database['database']}"
      backup_command << " > #{shared_path}/db/backup.sql"
      run backup_command rescue nil
    end

    desc "Restore the database"
    task :restore, :roles => :db do
      restore_command = "#{fetch(:mysql_prefix, '')}mysql"
      restore_command << " -uroot"
      restore_command << " -u#{database['username']}"
      restore_command << " -p#{database['password']}" if database['password']
      restore_command << " -hlocalhost"
      restore_command << " < #{shared_path}/db/backup.sql"
      run restore_command rescue nil
    end

    desc "Migrate the database"
    task :migrate, :roles => :db do
      # on_rollback { deploy.db.restore }
      run_remote_rake('db:migrate')
    end

    desc "Seed the database"
    task :seed, :roles => :db do
      # on_rollback { deploy.db.restore }
      run_remote_rake('db:seed')
    end

    desc "Reset the database"
    task :reset, :roles => :db do
      # on_rollback { deploy.db.restore }
      run_remote_rake('db:reset')
    end

    desc "Create the database"
    task :setup, :roles => :db do
      create_command = "#{fetch(:mysql_prefix, '')}mysql"
      create_command << " -u#{database['username']}"
      create_command << " -p#{database['password']}" if database['password']
      create_command << " -e 'CREATE DATABASE IF NOT EXISTS `#{database['database']}` CHARACTER SET UTF8'"
      run create_command
    end

    desc "Symlink the database configuration"
    task :symlink, :roles => :app do
      run "ln -sf #{shared_path}/config/database.yml #{current_path}/config/database.yml"
    end

  end
end
