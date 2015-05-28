class AddExternalLinkToBook < ActiveRecord::Migration
  def change
    add_column  :books, :external_link, :string, default: nil
  end
end
