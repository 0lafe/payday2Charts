class UpdateSteamItemData < ActiveRecord::Migration[8.0]
  def change
    change_column_null :steam_items, :steam_item_data_id, false
    remove_column :steam_items, :class_id, :string
  end
end
