class ChangeReturnDaysOfBook < ActiveRecord::Migration
  def change
    change_column :books,:return_days, :integer, default: 7
  end
end
