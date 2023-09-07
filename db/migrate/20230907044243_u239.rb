class U239 < ActiveRecord::Migration[7.0]
  def change
    add_column :weapon_stats, :weapon_used_bessy, :integer
    add_column :weapon_stats, :melee_used_piggy_hammer, :integer
    add_column :weapon_stats, :weapon_kills_bessy, :integer
    add_column :weapon_stats, :weapon_shots_bessy, :integer
    add_column :weapon_stats, :weapon_hits_bessy, :integer
    add_column :weapon_stats, :melee_kills_piggy_hammer, :integer
    add_column :weapon_stats, :weapon_charm_used_wpn_fps_upg_charm_deadgame, :integer
    add_column :weapon_stats, :weapon_charm_used_wpn_fps_upg_charm_deadgame_alt, :integer
    
    add_column :player_stats, :mask_used_roclown, :integer
    add_column :player_stats, :suit_used_roclown, :integer
    add_column :player_stats, :mask_used_gabhelm, :integer
    add_column :player_stats, :mask_used_bossflagmask, :integer
    add_column :player_stats, :suit_used_bossflag, :integer
    add_column :player_stats, :suit_used_sneak_suit_default, :integer
    add_column :player_stats, :suit_used_sneak_suit_camo, :integer
    add_column :player_stats, :suit_used_thug_gold, :integer
    add_column :player_stats, :suit_used_hacksuit, :integer
    add_column :player_stats, :suit_used_dgame_default, :integer
    add_column :player_stats, :suit_used_dgame_white, :integer
    add_column :player_stats, :suit_used_gangzsta_default, :integer
    add_column :player_stats, :suit_used_gangzsta_yellow, :integer
    add_column :player_stats, :suit_used_gangzsta_red, :integer
    add_column :player_stats, :suit_used_gangzsta_blue, :integer
    add_column :player_stats, :mask_used_guldgris, :integer
    add_column :player_stats, :mask_used_hackmask, :integer
    add_column :player_stats, :mask_used_splitcrim, :integer
    add_column :player_stats, :mask_used_teddymoo, :integer
    add_column :player_stats, :mask_used_zoothat_black, :integer
    add_column :player_stats, :mask_used_zoothat_blue, :integer
    add_column :player_stats, :mask_used_zoothat_red, :integer
    add_column :player_stats, :mask_used_zoothat_yellow, :integer
    
    add_column :misc_stats, :level_deep, :integer
    add_column :misc_stats, :job_deep, :integer
    add_column :misc_stats, :contract_deep_win, :integer
    add_column :misc_stats, :contract_deep_win_dropin, :integer
    add_column :misc_stats, :contract_deep_fail, :integer
    add_column :misc_stats, :gloves_used_roclogrip, :integer
    add_column :misc_stats, :enemy_kills_deep_boss, :integer
    add_column :misc_stats, :gloves_used_hackglove, :integer
    add_column :misc_stats, :enemy_kills_piggydozer, :integer
  end
end
