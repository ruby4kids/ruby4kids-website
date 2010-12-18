class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table "accounts", :force => true do |t|
      t.column "username",        :string
      t.column "hashed_password", :string
      t.column "salt",            :string
      t.column "email",           :string
      t.column "status",     :string
      t.column :person_id, :integer
    end
  end

  def self.down
    drop_table "accounts"
  end
end
