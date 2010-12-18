class Role < ActiveRecord::Base
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :rights
  
  def has_right_for?(action_name, controller_name) #Does this Role have a specific right
    rights.detect{ |right| right.has_right_for?(action_name, controller_name) }
  end
  
  
end
