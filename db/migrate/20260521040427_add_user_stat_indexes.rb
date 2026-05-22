class AddUserStatIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :user_stats, [:user_id, :stat_id], unique: true
    add_index :user_stats, [:stat_id, :value]
  end
end
