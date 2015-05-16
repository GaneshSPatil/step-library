class AddDefaultValueToAvailabilityOfBookCopy < ActiveRecord::Migration
  def change
    change_column :book_copies, :status, :string, :default => 'Available'
  end
end
