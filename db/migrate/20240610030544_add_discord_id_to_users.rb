class AddDiscordIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :discord_id, :string
  end
end
