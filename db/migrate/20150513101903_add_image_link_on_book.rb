class AddImageLinkOnBook < ActiveRecord::Migration
  def change
    add_column :books, :image_link, :string, default: 'default-book.png'
  end
end
