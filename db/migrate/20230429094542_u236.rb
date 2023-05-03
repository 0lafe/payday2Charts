class U236 < ActiveRecord::Migration[7.0]
  def change
    add_column :weapon_stats, :weapon_used_awp, :integer
    add_column :weapon_stats, :weapon_used_flamethrower_mk3, :integer
    add_column :weapon_stats, :weapon_used_kacchainsaw, :integer
    add_column :weapon_stats, :weapon_used_kacchainsaw_flamethrower, :integer
    add_column :weapon_stats, :weapon_used_supernova, :integer

    add_column :weapon_stats, :weapon_color_used_color_pxp4_01, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_02, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_03, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_04, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_05, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_06, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_07, :integer
    add_column :weapon_stats, :weapon_color_used_color_pxp4_08, :integer

    add_column :weapon_stats, :weapon_kills_awp, :integer
    add_column :weapon_stats, :weapon_kills_flamethrower_mk3, :integer
    add_column :weapon_stats, :weapon_kills_kacchainsaw, :integer
    add_column :weapon_stats, :weapon_kills_kacchainsaw_flamethrower, :integer
    add_column :weapon_stats, :weapon_kills_supernova, :integer

    add_column :weapon_stats, :weapon_shots_awp, :integer
    add_column :weapon_stats, :weapon_shots_flamethrower_mk3, :integer
    add_column :weapon_stats, :weapon_shots_kacchainsaw, :integer
    add_column :weapon_stats, :weapon_shots_kacchainsaw_flamethrower, :integer
    add_column :weapon_stats, :weapon_shots_supernova, :integer

    add_column :weapon_stats, :weapon_hits_awp, :integer
    add_column :weapon_stats, :weapon_hits_flamethrower_mk3, :integer
    add_column :weapon_stats, :weapon_hits_kacchainsaw, :integer
    add_column :weapon_stats, :weapon_hits_kacchainsaw_flamethrower, :integer
    add_column :weapon_stats, :weapon_hits_supernova, :integer
  end
end
