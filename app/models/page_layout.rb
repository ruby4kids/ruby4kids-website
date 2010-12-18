class PageLayout < ActiveRecord::Base
  
  has_many :web_pages
  belongs_to :website
  
protected
  def self.join_table_mappings
    return {
      "page_layout" => {
        "model_name" => PageLayout,
        "table_name" => "page_layouts",
        "join_relationships" => ""
      }
    }
  end
end
