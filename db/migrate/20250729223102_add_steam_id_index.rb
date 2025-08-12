class AddSteamIdIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :steam_id, unique: true
  end
end
