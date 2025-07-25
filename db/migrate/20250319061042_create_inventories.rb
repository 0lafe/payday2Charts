class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :steam_items do |t|
      t.belongs_to :user
      t.integer :amount, null: false
      t.string :class_id, null: false
    end
  end
end
