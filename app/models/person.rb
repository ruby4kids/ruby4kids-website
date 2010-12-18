class Person < ActiveRecord::Base
  
  has_one :account
  
  def full_name
    "#{self.first} #{self.last}"
  end
  
protected
  def self.join_table_mappings
    return {
      "person" => {
        "model_name" => Person,
        "table_name" => "people",
        "join_relationships" => ""
      }
    }
  end
end
