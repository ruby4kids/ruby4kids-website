class Attachment < ActiveRecord::Base
  
  has_attachment :storage => :file_system, :path_prefix => '/public/attachments'
  
  validates_uniqueness_of :filename
  
protected
  def self.join_table_mappings
    return {
      "attachment" => {
        "model_name" => Attachment,
        "table_name" => "attachments",
        "join_relationships" => ""
      }
    }
  end
end
