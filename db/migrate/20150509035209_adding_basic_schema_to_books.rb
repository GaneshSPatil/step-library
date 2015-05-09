class AddingBasicSchemaToBooks < ActiveRecord::Migration
  def change
    add_column :books, :isbn, :integer
    add_column :books, :title, :string
    add_column :books, :author, :string
  end
end
