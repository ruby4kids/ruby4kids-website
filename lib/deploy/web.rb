namespace :deploy do
  namespace :web do

    desc "Redirect all requests to the maintenance page"
    task :disable, :roles => :web, :except => { :no_release => true } do
      require 'erb'
      on_rollback { run "rm -f #{shared_path}/system/maintenance.html" }

      reason = ENV['REASON']
      deadline = ENV['UNTIL']

      template = File.read(File.expand_path('../../../config/templates/maintenance.html.erb', __FILE__))
      result = ERB.new(template).result(binding)

      put result, "#{shared_path}/system/maintenance.html", :mode => 0644
    end

    desc "Make the application web-accessible again"
    task :enable, :roles => :web, :except => { :no_release => true } do
      run "rm -f #{shared_path}/system/maintenance.html"
    end

  end
end
