class AddSteamFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :steam_name, :string
    add_column :users, :steam_avatar, :string
  end
end
