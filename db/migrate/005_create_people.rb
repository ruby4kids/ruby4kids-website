class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :company_id, :integer
      t.column :first, :string
      t.column :last, :string
      t.column :email, :string
      t.column :title, :string
      t.column :category, :string
      t.column :phone, :string
      t.column :fax, :string
      t.column :comment, :text
      t.column :status, :string
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
