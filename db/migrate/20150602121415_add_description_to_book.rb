class AddDescriptionToBook < ActiveRecord::Migration
  def change
    add_column  :books, :page_count, :integer, default: nil
    add_column  :books, :publisher, :string, default: nil
    add_column  :books, :description, :string, default: nil
  end
end
