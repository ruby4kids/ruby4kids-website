class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.column :parent_id,  :integer
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
      t.column :db_file_id, :integer
      t.timestamps
    end
    
    # only for db-based files
    create_table :db_files, :force => true do |t|
         t.column :data, :binary, :limit => 10.megabyte
    end
  end

  def self.down
    drop_table :pictures
  end
end
