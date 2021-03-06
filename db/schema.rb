# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130402150759) do

  create_table "cards", :force => true do |t|
    t.integer  "list_id"
    t.integer  "trello_account_id"
    t.string   "uid"
    t.string   "name"
    t.string   "trello_short_id"
    t.string   "trello_closed"
    t.string   "trello_url"
    t.string   "trello_board_id"
    t.string   "trello_list_id"
    t.integer  "position"
    t.datetime "due_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "project_id"
  end

  add_index "cards", ["list_id"], :name => "index_cards_on_list_id"
  add_index "cards", ["project_id"], :name => "index_cards_on_project_id"
  add_index "cards", ["trello_account_id"], :name => "index_cards_on_trello_account_id"

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.integer  "trello_account_id"
    t.string   "uid"
    t.string   "trello_board_id"
    t.boolean  "trello_closed"
    t.string   "role"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "position"
  end

  add_index "lists", ["position"], :name => "index_lists_on_position"
  add_index "lists", ["project_id"], :name => "index_lists_on_project_id"
  add_index "lists", ["trello_account_id"], :name => "index_lists_on_trello_account_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.string   "trello_url"
    t.integer  "trello_organization_id"
    t.boolean  "trello_closed"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "trello_name"
    t.integer  "owner_id"
    t.integer  "trello_account_id"
    t.string   "time_zone"
  end

  add_index "projects", ["owner_id"], :name => "index_projects_on_owner_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "trello_accounts", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.string   "secret"
    t.string   "uid"
    t.string   "trello_avatar_id"
    t.string   "trello_url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "authentication_token"
    t.string   "provider"
    t.string   "uid"
    t.date     "test_date"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
