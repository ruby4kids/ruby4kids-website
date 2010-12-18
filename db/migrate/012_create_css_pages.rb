class CreateCssPages < ActiveRecord::Migration
  def self.up
    create_table :css_pages do |t|
      t.column :website_id, :integer
      t.column :name, :string
      t.column :content, :text
      t.timestamps
    end
    
    create_table :css_pages_page_layouts, :id => false do |t|
      t.column :css_page_id, :integer
      t.column :page_layout_id, :integer
    end
    
    create_table :css_pages_web_pages, :id => false do |t|
      t.column :css_page_id, :integer
      t.column :page_layout_id, :integer
    end
    
    
  end

  def self.down
    drop_table :css_pages
  end
end
