module AccountMonitor
  def self.included(m)    
    m.class_eval do
      @@account_monitor_enabled = true
      cattr_accessor :account_monitor_enabled
      before_create :set_created_by
      before_update :set_updated_by
    end
  end
  
  def current_person_id
    Thread.current["person_id"] || AppConstant.config["system_person_id"]
  end
  
  def set_updated_by
    return true unless self.class.account_monitor_enabled
    self.updated_by = current_person_id if respond_to?(:updated_by) && current_person_id
  end
  
  def set_created_by
    return true unless self.class.account_monitor_enabled
    self.created_by = current_person_id if respond_to?(:created_by)
    self.updated_by = current_person_id if respond_to?(:updated_by)
  end
    
  def created_by_name
    begin
      Person.find(created_by).full_name
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def updated_by_name
    begin
      Person.find(updated_by).full_name
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end

ActiveRecord::Base.class_eval do
  include AccountMonitor
end
