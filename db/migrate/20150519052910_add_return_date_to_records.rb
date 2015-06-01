class AddReturnDateToRecords < ActiveRecord::Migration
  def change
    add_column :records, :return_date, :datetime
  end
end
