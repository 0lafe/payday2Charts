class AddBannedIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :banned
  end
end
