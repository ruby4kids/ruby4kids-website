class CreateRoles < ActiveRecord::Migration
  def self.up
      create_table "roles", :force => true do |t|
        t.column "name",                    :string
      end
    
    create_table "accounts_roles", :id => false, :force => true do |t|
      t.integer "role_id"
      t.integer "account_id"
    end
  end

  def self.down
    drop_table :roles
    drop_table :accounts_roles
  end
  
end
