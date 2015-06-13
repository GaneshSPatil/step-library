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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150612103850) do

  create_table "book_copies", force: :cascade do |t|
    t.text     "isbn",                             null: false
    t.string   "status",     default: "Available"
    t.integer  "book_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "copy_id"
  end

  add_index "book_copies", ["book_id"], name: "index_book_copies_on_book_id"

  create_table "book_tags", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "book_tags", ["book_id"], name: "index_book_tags_on_book_id"
  add_index "book_tags", ["tag_id"], name: "index_book_tags_on_tag_id"

  create_table "books", force: :cascade do |t|
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "isbn",                                       null: false
    t.string   "title"
    t.string   "author"
    t.string   "image_link",    default: "default-book.png"
    t.string   "external_link"
    t.integer  "page_count"
    t.string   "publisher"
    t.string   "description"
    t.integer  "return_days",   default: 7
  end

  add_index "books", ["isbn"], name: "index_books_on_isbn", unique: true

  create_table "records", force: :cascade do |t|
    t.integer  "book_copy_id"
    t.integer  "user_id"
    t.datetime "borrow_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "return_date"
    t.datetime "expected_return_date"
  end

  add_index "records", ["book_copy_id"], name: "index_records_on_book_copy_id"
  add_index "records", ["user_id"], name: "index_records_on_user_id"

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",              default: ""
    t.string   "encrypted_password", default: "",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "role",               default: "Intern"
    t.string   "name"
    t.boolean  "enabled",            default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
