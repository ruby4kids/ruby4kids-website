namespace :web_shell do
	desc "Initial database load ... "
	task :initial_load => :environment do
	  p = Person.find_or_create_by_email('amorales@opnet.com')
	  p.first = 'Alberto'
	  p.last = 'Morales'
	  p.save
	  
	  u = Account.find_or_create_by_person_id(p.id)
	  u.username = 'amorales'
	  u.password = 'testing'
	  u.email = 'amorales@opnet.com'
	  u.status = 'Active'
	  u.save
	  
	  r = Role.find_or_create_by_name('superuser')
	  r.accounts << u unless r.accounts.include? u
	  
	  Right.synchronize_with_controllers
	  
	  r.rights = Right.find(:all)
  end
end