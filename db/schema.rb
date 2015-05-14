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

ActiveRecord::Schema.define(version: 20150513111534) do

  create_table "book_copies", force: :cascade do |t|
    t.text     "isbn",       null: false
    t.string   "status"
    t.integer  "book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "book_copies", ["book_id"], name: "index_book_copies_on_book_id"

  create_table "books", force: :cascade do |t|
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "isbn",                                    null: false
    t.string   "title"
    t.string   "author"
    t.string   "image_link", default: "default-book.png"
  end

  add_index "books", ["isbn"], name: "index_books_on_isbn", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",              default: "",       null: false
    t.string   "encrypted_password", default: "",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "role",               default: "Intern"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
