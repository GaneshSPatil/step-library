class CreateBookCopies < ActiveRecord::Migration
  def change
    create_table :book_copies do |t|
      t.text :isbn, :null => false
      t.string :status
      t.references :book
      t.timestamps null: false
    end
    add_index :book_copies, :book_id
  end
end
