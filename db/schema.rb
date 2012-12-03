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

ActiveRecord::Schema.define(:version => 20121203192201) do

  create_table "comments", :force => true do |t|
    t.string   "body"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "task_id"
  end

  create_table "hits", :force => true do |t|
    t.string   "code"
    t.string   "h_id"
    t.string   "type_id"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "task_id"
  end

  create_table "points", :force => true do |t|
    t.string   "body"
    t.boolean  "isPro"
    t.integer  "suggestion_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "turk_id"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "task_id"
    t.integer  "turk_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "suggestions", :force => true do |t|
    t.integer  "interation_id"
    t.string   "body"
    t.integer  "vote_count"
    t.boolean  "sent",             :default => false
    t.boolean  "accepted"
    t.integer  "rating"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "suggestable_id"
    t.string   "suggestable_type"
    t.integer  "task_id"
    t.integer  "price"
    t.string   "product_name"
    t.string   "product_link"
    t.string   "image_url"
    t.string   "retailer"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "body"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "finished",           :default => false
  end

  create_table "turks", :force => true do |t|
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "access_key_id"
    t.string   "secret_access_key"
    t.string   "password_digest"
    t.string   "email"
    t.string   "phone_number"
  end

  create_table "votes", :force => true do |t|
    t.integer  "suggestion_id"
    t.integer  "turk_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
