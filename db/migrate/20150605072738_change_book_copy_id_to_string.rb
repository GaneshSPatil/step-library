class ChangeBookCopyIdToString < ActiveRecord::Migration
  def change
    change_column :book_copies, :copy_id, :string
  end
end
