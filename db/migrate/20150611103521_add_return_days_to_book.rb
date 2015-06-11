class AddReturnDaysToBook < ActiveRecord::Migration
  def change
    add_column :books,:return_days, :string, default: 7
  end
end
