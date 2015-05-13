class AddUniqueAndNotNullConstraintOnIsbnOfBook < ActiveRecord::Migration
  def change
    add_index :books, :isbn, :unique => true
    change_column :books, :isbn, :text, :null => false
  end
end
