class RemoveUsernameFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :username
  end

  def self.down
    add_column :users, :username, :string, null: false
    add_index :users, :username, unique: true
  end
end
