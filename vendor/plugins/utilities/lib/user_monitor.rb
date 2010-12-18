module ActiveRecord

  module UserMonitor
   
    #Added class variable  
    @@user_monitor_enabled = true

    def self.user_monitor_enabled
      @@user_monitor_enabled
    end
    
    def self.user_monitor_enabled=(val)
      @@user_monitor_enabled = val
    end
        
    def self.included(base)

      base.class_eval do
        alias_method :create_without_user, :create
        alias_method :create, :create_with_user

        alias_method :update_without_user, :update
        alias_method :update, :update_with_user
      end
      
      def current_user_id
        current = Thread.current['person_id']

        if current == nil
          current = AppConstant.config["system_person_id"]
        end
        return current
      end      
    end

    def create_with_user
       if !current_user_id.nil? && @@user_monitor_enabled
        self[:created_by] = current_user_id if respond_to?(:created_by) && created_by.nil?
        self[:updated_by] = current_user_id if respond_to?(:updated_by)
      end
      create_without_user
    end

    def update_with_user
      if @@user_monitor_enabled
        self[:updated_by] = current_user_id if respond_to?(:updated_by) && !current_user_id.nil?
      end 
      update_without_user
    end

    def created_by_name
      begin
          Person.find(self[:created_by]).full_name
        rescue ActiveRecord::RecordNotFound
          nil
      end
    end
    
    def updated_by_name
      begin
        Person.find(self[:updated_by]).full_name
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end

end