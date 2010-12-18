require 'mongrel_cluster/recipes'

app_target = ENV["DEPLOY_APP_SERVER"]
sync_target = ENV["DEPLOY_SYNC_SERVER"]
svn_repos = ENV["DEPLOY_REPOS"]
env = ENV["DEPLOY_ENV"]
tag = ENV["DEPLOY_TAG"]

set :repository, svn_repos

role :app, app_target
role :web, app_target
role :sync, sync_target
role :db, app_target, :primary => true
role :staging_db, app_target

set :user, "deploy"            # defaults to the currently logged in user
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :mongrel_etc_link, "/etc/mongrel_cluster/#{application}.yml"
set :mongrel_port, 3000
set :mongrel_address, "127.0.0.1"
set :httpd_file, "/usr/local/apache2/conf/rails/#{application}.conf"
set :running_applications, []

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)
#
# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    symlink
    migrate
  end

  restart
end

desc "A task to generate the monit configuration file"
task :generate_monit_config, :roles => :sync do
  if env == "p"
    run %{echo "" > #{current_path}/config/monit.conf}
    Dir["#{current_path}/lib/daemons/*.rb"].map {|x| File.basename(x)}.each do |daemon|
      run <<-EOS
        echo "check process #{daemon} with pidfile #{current_path}/lib/daemons/#{daemon}.pid" >> #{current_path}/config/monit.conf &&
        echo "  group #{application}" >> #{current_path}/config/monit.conf
      EOS
    end
  end
end

desc "A task to restart monit"
task :restart_monit, :roles => :sync do
  if env == "p"
    run "monit quit ; sleep 10 ; monit -c /home/deploy/.monitrc"
  end
end

# This task is a capistrano hook.  It will be called after the deploy task runs.
#task :after_deploy do

desc "A task to start application daemons"
task :start_daemon, :roles => :sync do
  run <<-CMD
    if  [[ -x #{current_path}/script/daemons ]]; then
      RAILS_ENV=production ruby #{current_path}/script/daemons start ;
    fi
  CMD
end

desc "A task to stop application daemons"
task :stop_daemon, :roles => :sync do
  daemon_exists = false

  run "if [[ -x #{current_path}/script/daemons ]] ; then echo yes ; fi" do |channel, stream, data|
    if data =~ /yes/
      daemon_exists = true
    end
  end

  if !daemon_exists
    next
  end

  get_pids = lambda do |daemon|
    pids = []
    begin
      run "pgrep -f #{daemon}" do |channel, stream, data|
        pids = data.scan(/\d+/).map {|x| x.to_i}
      end
    rescue Capistrano::Command::Error
    end
    pids
  end

  run "cd #{current_path} ; ruby script/daemons stop"

  Dir["#{current_path}/lib/daemons/*.rb"].map {|x| File.basename(x)}.each do |daemon|
    puts "Waiting for #{daemon} to exit gracefully"
    pids = []

    15.times do
      pids = get_pids.call(daemon)
      break if pids.empty?
      sleep 5
    end

    if pids.any?
      puts "Killing #{daemon}"

      pids.each do |pid|
        run "kill -s SIGKILL #{pid} ; true"
      end
    end
  end
end

desc " A task to stop and start application daemons"
task :restart_daemon, :roles => :sync do
  stop_daemon
  start_daemon
end

desc " A task to do a application's very first deployment"
task :initial_deploy do
  transaction do
    setup
    update_code
    symlink
    create_mongrel_config
    create_httpd_config
    create_recipe
  end
  migrate
  run_fix_method
  set_script_permission
  generate_monit_config
  restart_monit
  restart_daemon
  restart_mongrel_cluster
end

desc "Deploy task that overwrites default deploy task"
task :deploy do
  stop_daemon
  stop_mongrel_cluster
  transaction do
    update_code
    symlink
  end
  migrate
  run_fix_method
  set_script_permission
  generate_monit_config
  restart_monit
  start_daemon
  start_mongrel_cluster
end
    
desc " A task to create new mongrel_cluster task for this application"
task :create_mongrel_config, :roles => :app do
  mongrel_etc_dir = "/etc/mongrel_cluster"
  argv = []
  argv << "mongrel_rails cluster::configure"
  argv << "-N 3"
  argv << "-e production"
  argv << "-C #{mongrel_conf}"
  argv << "-c #{current_path}"
  argv << "-P log/mongrel.pid"
  argv << "--user #{user}"
  argv << "--group #{user}"
  argv << "--prefix /#{application}"
  argv << "-a #{mongrel_address}"
  cmd = argv.join " "
  sudo "chown #{user}:#{user} #{mongrel_etc_dir}"
  run <<-MONGRELPORT
    if [[ ! -f #{mongrel_conf} ]]; then
      top_port=`grep 'port:' /etc/mongrel_cluster/* |awk -F: '{print $NF}'|sed -e 's/\"//g'|sort -g -r |head -1` ;
      if [[ -n $top_port ]]; then
        top_port=`expr ${top_port} + 10`;
      else 
        top_port=3000;
      fi; 
      #{cmd} -p ${top_port} &&
      svn add #{mongrel_conf}&&
      svn commit #{mongrel_conf} -m 'add mongrel_cluster file to applicaiton config';
    fi; 
    if [[ ! -f #{mongrel_etc_link} ]]; then
      ln -s #{mongrel_conf} #{mongrel_etc_link} ;
    fi;
  MONGRELPORT
  #get the mongrel port for this new app from app server
  run "grep 'port:' #{mongrel_etc_link}|awk -F: '{print $NF}'|sed -e 's/\"//g' |sort -g|head -1" do |channel, stream, data|
    set :mongrel_port, data.to_i
    puts mongrel_port
  end
end

desc " A task that creats cluster_balancer information in Apache configuration"
task :create_httpd_config, :roles => :web do
  run <<-CMD
    echo "<Proxy balancer://#{application}_cluster>" >  #{httpd_file} &&
    echo "  BalancerMember http://#{mongrel_address}:#{mongrel_port.to_s}" >>#{httpd_file} &&
    echo "  BalancerMember http://#{mongrel_address}:#{(mongrel_port+1).to_s}" >>#{httpd_file} &&
    echo "  BalancerMember http://#{mongrel_address}:#{(mongrel_port+2).to_s}" >>#{httpd_file} &&
    echo "</Proxy>" >>#{httpd_file} 
  CMD
  sudo "/etc/init.d/httpd restart"
end

desc "A task that creates deploy.recipes for the new application"
task :create_recipe, :roles => :app do
  recipe_file="#{current_path}/config/deploy.rb"
  recipe_tmp="/tmp/recipes.#{Process.pid}"
  target=File.new(recipe_tmp,"w")
  open(__FILE__).each do |line|
    line.gsub!(/^#set :application,\s+'<APPLICATION>'\s*$/,"set :application, '#{application}'\n")
    target.write(line)
  end
  target.close
  set :recipe_not_exist, 0
  run " [[ -f #{recipe_file} ]]; echo \$? " do |channel,stream,data|
    set :recipe_not_exist,data.to_i
  end

  if recipe_not_exist >0
    put(File.read(recipe_tmp),recipe_file) 
    sudo "chown #{user}:#{user} #{recipe_file}"
    run "svn add #{recipe_file}"
    run "svn commit #{recipe_file} -m 'add recipe file to applicaiton config'"
  end
  File.delete(recipe_tmp)
end
   
desc " A task to remove an application deployment on the app server"
task :remove_app, :roles => :app do
  stop_daemon
  stop_mongrel_cluster
  delete "#{deploy_to}", :recursive=>true
  delete "#{mongrel_etc_link}"
end

desc " A task to remove httpd configuration part on web server"
task :remove_web, :roles => :web do
  delete "#{httpd_file}"
  sudo "/etc/init.d/httpd restart"
end

desc " A task to remove an application from the servers"
task :remove_deploy do
  remove_app
  remove_web
end

desc " A task to run release fix method for production/staging system"
task :run_fix_method, :roles => :app do
  unless env == "d"
    puts "Run fix method for this release"
    method_to_run="#{current_path}/lib/Fix_Release_#{tag}.rb"
    run <<-FIXMETHOD
      if [[ -r #{method_to_run} ]]; then
        echo "Running fix method #{method_to_run}";
        cd #{current_path}/lib;
        RAILS_ENV=production ruby #{method_to_run};
      fi
    FIXMETHOD
  end 
end

desc " A task to set excution permission for some application files"
task :set_script_permission, :roles => :app do
   run <<-FIXDAEMON
     chmod -R 774 #{current_path}/script &&
     if [[ -d #{current_path}/lib/daemons ]]; then
       chmod -R 744 #{current_path}/lib/daemons;
     fi
   FIXDAEMON
end

desc "A task to stop mongrel_cluster flexibly the original stop_mongrel_cluster task"
task :stop_mongrel_cluster, :roles => :app do
  sudo <<-STOPMONGRELCLUSTER
    bash -c " if [[ -r #{mongrel_conf} ]]; then mongrel_rails cluster::stop  -C #{mongrel_conf} ; fi "
  STOPMONGRELCLUSTER
end

desc " A task that stops all applications on target app servers"
task :stop_all_applications, :roles => :app do
  run "ls /u/apps/*/current/log/mongrel*.pid" do  |channel, stream, data|
    running_applications.push(data.split(/\s+/))
  end
  running_applications.flatten!.collect! do |entry|
    entry.sub!(/^\/u\/apps\/([^\/]+)\/current.+$/,'\1')
  end
  running_applications.uniq!.each do |app|
    puts "==#{app}=="
    run <<-STOPCOMMANDS
      mongrel_rails cluster::stop -C /u/apps/#{app}/current/config/mongrel_cluster.yml &&
      if [[ -x "/u/apps/#{app}/current/script/daemons" ]]; then
        /u/apps/#{app}/current/script/daemons stop;
        sleep 60;
        /u/apps/#{app}/current/script/daemons stop;
      fi
    STOPCOMMANDS
  end
end

desc " A task that start all (previously stopped)applications on target app servers"
task :start_all_applications, :roles => :app do
  puts running_applications.length
  unless running_applications.length >0
    run "ls /u/apps" do  |channel,stream,data|
    running_applications.push(data.split(/\s+/))
    end
  end
  running_applications.flatten!.uniq.each do |app|
    puts "===#{app}=="
    run <<-STARTCOMMANDS
      mongrel_rails cluster::restart -C /u/apps/#{app}/current/config/mongrel_cluster.yml &&
      if [[ -x "/u/apps/#{app}/current/script/daemons" ]]; then
        /u/apps/#{app}/current/script/daemons stop;
        /u/apps/#{app}/current/script/daemons start;
      fi
    STARTCOMMANDS
  end
end