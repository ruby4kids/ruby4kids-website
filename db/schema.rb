# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "accounts", :force => true do |t|
    t.string  "username"
    t.string  "hashed_password"
    t.string  "salt"
    t.string  "email"
    t.string  "status"
    t.integer "person_id"
  end

  create_table "accounts_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "account_id"
  end

  create_table "attachments", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "css_pages", :force => true do |t|
    t.integer  "website_id"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "css_pages_page_layouts", :id => false, :force => true do |t|
    t.integer "css_page_id"
    t.integer "page_layout_id"
  end

  create_table "css_pages_web_pages", :id => false, :force => true do |t|
    t.integer "css_page_id"
    t.integer "page_layout_id"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.integer  "website_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_layouts", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.text     "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "company_id"
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "title"
    t.string   "category"
    t.string   "phone"
    t.string   "fax"
    t.text     "comment"
    t.string   "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "web_pages", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "page_layout_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "websites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
