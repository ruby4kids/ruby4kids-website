class Right < ActiveRecord::Base
  has_and_belongs_to_many :roles
	before_validation :auto_name
  validates_presence_of :controller, :action, :name
  validates_uniqueness_of :name
  
	def auto_name
		self.name = self.controller.camelize + "Controller." + self.action
	end
	
  def has_right_for?(action_name, controller_name)
    action == action_name && controller == controller_name
  end

  def self.has_right(right_hash, right_name)
    if right_hash.detect{|r| r==right_name} != nil then true else false end
  end

	def self.update_rights(role, accounts = nil, options = {})
		all_rights = synchronize_with_controllers()
		
		r = Role.find_or_create_by_name(role)

		if accounts
			r.accounts = accounts
		end

		if options[:except]
			rights = all_rights.reject {|x| options[:except].include?(x.controller)}
		elsif options[:only]
			rights = all_rights.select {|x| options[:only].include?(x.controller)}
		else
		  rights = all_rights
		end

		r.rights.delete(all_rights)
		r.rights << rights
	end

  # Ensure that the table has one entry for each controller/action pair
  def self.synchronize_with_controllers
    # weird hack. otherwise ActiveRecord has no idea about the superclass of any
    # ActionController stuff...
    require RAILS_ROOT + "/app/controllers/application"

    # Load all the controller files
    controller_files = Dir[RAILS_ROOT + "/app/controllers/**/*_controller.rb"]

    # we need to load all the controllers...
    controller_files.each do |file_name|
      require file_name #if /_controller.rb$/ =~ file_name
    end

		rights = []

    # Find the actions in each of the controllers, and add them to the database
    subclasses_of(ApplicationController).each do |controller|
      controller.public_instance_methods(false).each do |action|
        next if action =~ /return_to_main|component_update|component/

        if find_all_by_controller_and_action(controller.controller_path, action).empty?
          self.new(:name => "#{controller}.#{action}", :controller => controller.controller_path, :action => action).save!
          logger.info "added: #{controller} - #{controller.controller_path}, #{action}"
        end

				rights << find(:first, :conditions => ["controller = ? and action = ?", controller.controller_path, action])
      end
      # The following thanks to Tom Styles 
      # Then check to make sure that all the rights for that controller in the database
      # still exist in the controller itself
      self.find(:all, :conditions => ['controller = ?', controller.controller_path]).each do |right_to_go|
        unless controller.public_instance_methods(false).include?(right_to_go.action)
          right_to_go.destroy
        end
      end
    end

		return rights
  end
end
