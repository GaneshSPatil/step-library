class CreateBookTags < ActiveRecord::Migration
  def change
    create_table :book_tags do |t|
      t.references :book
      t.references :tag

      t.timestamps null: false
    end
    add_index :book_tags, :book_id
    add_index :book_tags, :tag_id

  end
end
