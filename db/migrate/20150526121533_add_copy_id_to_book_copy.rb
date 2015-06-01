class AddCopyIdToBookCopy < ActiveRecord::Migration
  def change
    add_column :book_copies, :copy_id, :integer
  end
end
