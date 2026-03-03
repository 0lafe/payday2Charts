class AddStunBatton < ActiveRecord::Migration[8.0]
  def change
    add_column :weapon_stats, :melee_used_funder_strike, :integer
    add_column :weapon_stats, :melee_kills_funder_strike, :integer
  end
end
