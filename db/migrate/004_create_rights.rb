class CreateRights < ActiveRecord::Migration
  def self.up
    create_table "rights", :force => true do |t|
      t.string "name"
      t.string "action"
      t.string "controller"
    end

    create_table "rights_roles", :id => false, :force => true do |t|
      t.integer "right_id"
      t.integer "role_id"
    end

    add_index "rights_roles", ["right_id"], :name => "rights_roles_right_id_index"
    add_index "rights_roles", ["role_id"], :name => "rights_roles_role_id_index"
  end

  def self.down
    drop_table :rights
    drop_table :rights_roles
  end
end
