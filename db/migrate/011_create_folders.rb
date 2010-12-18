class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.column :name, :string
      t.column :website_id, :integer
      t.column :parent_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :folders
  end
end
