class OptimizeSteamItemData < ActiveRecord::Migration[8.0]
  def change
    add_reference :steam_items, :steam_item_data, foreign_key: true
  end
end
