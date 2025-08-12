class AddPriceToSkins < ActiveRecord::Migration[8.0]
  def change
    add_column :steam_item_data, :value, :decimal, precision: 8, scale: 2
    add_column :steam_item_data, :item_nameid, :integer
  end
end
