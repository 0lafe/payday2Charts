class Missing245Stats < ActiveRecord::Migration[8.0]
  def change
    add_column :weapon_stats, :weapon_used_welrod, :integer
    add_column :weapon_stats, :weapon_kills_welrod, :integer
    add_column :weapon_stats, :weapon_shots_welrod, :integer
    add_column :weapon_stats, :weapon_hits_welrod, :integer
    add_column :weapon_stats, :grenade_used_laser_watch, :integer
    add_column :misc_stats, :gadget_used_spy_camera, :integer
  end
end
