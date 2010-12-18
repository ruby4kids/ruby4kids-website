class CreateWebPages < ActiveRecord::Migration
  def self.up
    create_table :web_pages do |t|
      t.column :name, :string
      t.column :content, :text
      t.column :page_layout_id, :integer
      t.column :website_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :web_pages
  end
end
