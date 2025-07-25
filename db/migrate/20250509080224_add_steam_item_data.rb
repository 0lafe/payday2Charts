class AddSteamItemData < ActiveRecord::Migration[8.0]
  def change
    create_table :steam_item_data do |t|
      t.text :icon_url, null: false
      t.string :name, null: false
      t.string :name_color, null: false
      t.boolean :tradable, null: false
      t.boolean :marketable, null: false
      t.boolean :commodity, null: false
      t.string :item_type, null: false
      t.string :quality
      t.string :rarity
      t.string :bonus
      t.string :collection
    end
  end
end
