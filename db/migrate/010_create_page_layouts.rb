class CreatePageLayouts < ActiveRecord::Migration
  def self.up
    create_table :page_layouts do |t|
      t.column :name, :string
      t.column :content, :text
      t.column :website_id, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :page_layouts
  end
end
