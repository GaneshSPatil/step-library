class CreateRecords < ActiveRecord::Migration
    create_table :records do |t|
      t.references :book_copy
      t.references :user
      t.datetime :borrow_date
      t.timestamps null: false
    end
    add_index :records, :book_copy_id
    add_index :records, :user_id
end
