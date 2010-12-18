namespace :web_shell do
	desc "Initial database load ... "
	task :sync_with_controllers => :environment do
	  
	  u = Account.find_by_username('amorales')
	  Right.synchronize_with_controllers
	  
	  r = Role.find_or_create_by_name('superuser')
	  r.accounts << u unless r.accounts.include? u
	  r.rights = Right.find(:all)
  end
end