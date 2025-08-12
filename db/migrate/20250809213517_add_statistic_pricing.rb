class AddStatisticPricing < ActiveRecord::Migration[8.0]
  def change
    remove_column :steam_item_data, :value

    add_column :steam_item_data, :average_price, :decimal, precision: 8, scale: 2
    add_column :steam_item_data, :median_price, :decimal, precision: 8, scale: 2
    add_column :steam_item_data, :lowest_price, :decimal, precision: 8, scale: 2
    add_column :steam_item_data, :highest_price, :decimal, precision: 8, scale: 2
  end
end
