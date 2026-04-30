class U245 < ActiveRecord::Migration[8.0]
  def change
    add_column :weapon_stats, :weapon_used_pmm, :integer
    add_column :weapon_stats, :weapon_kills_pmm, :integer
    add_column :weapon_stats, :weapon_shots_pmm, :integer
    add_column :weapon_stats, :weapon_hits_pmm, :integer
    add_column :weapon_stats, :weapon_used_x_pmm, :integer
    add_column :weapon_stats, :weapon_kills_x_pmm, :integer
    add_column :weapon_stats, :weapon_shots_x_pmm, :integer
    add_column :weapon_stats, :weapon_hits_x_pmm, :integer
    add_column :weapon_stats, :weapon_used_dart, :integer
    add_column :weapon_stats, :weapon_kills_dart, :integer
    add_column :weapon_stats, :weapon_shots_dart, :integer
    add_column :weapon_stats, :weapon_hits_dart, :integer
    add_column :weapon_stats, :weapon_used_speen, :integer
    add_column :weapon_stats, :weapon_kills_speen, :integer
    add_column :weapon_stats, :weapon_shots_speen, :integer
    add_column :weapon_stats, :weapon_hits_speen, :integer
  end
end
