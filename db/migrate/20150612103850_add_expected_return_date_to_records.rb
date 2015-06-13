class AddExpectedReturnDateToRecords < ActiveRecord::Migration
  def change
    add_column :records, :expected_return_date, :datetime
  end
end
