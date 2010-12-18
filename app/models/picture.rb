class Picture < ActiveRecord::Base
  
  validates_uniqueness_of :filename
  
  has_attachment :storage => :db_file

  
  
protected
  def self.join_table_mappings
    return {
      "picture" => {
        "model_name" => Picture,
        "table_name" => "pictures",
        "join_relationships" => ""
      }
    }
  end
end
