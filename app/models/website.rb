class Website < ActiveRecord::Base
  
  has_many :web_pages
  has_many :page_layouts
  
  def self.default
    self.find_or_create_by_name("ruby4kids")
  end
  
protected
  def self.join_table_mappings
    return {
      "website" => {
        "model_name" => Website,
        "table_name" => "websites",
        "join_relationships" => ""
      }
    }
  end
end
