class UnifyStats < ActiveRecord::Migration[8.0]
  def change
    create_table :stats do |t|
      t.timestamps
      t.string :name, null: false
      t.string :stat_type, null: false

      t.index :name, unique: true
    end

    create_table :user_stats do |t|
      t.timestamps

      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :stat, null: false, foreign_key: true

      t.integer :value, null: false

      # t.index [:user_id, :stat_id], unique: true
      # t.index [:stat_id, :value]
    end
  end
end
