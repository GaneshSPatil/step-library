class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :user, :provider, :string
    add_column :user, :uid, :string
  end
end
