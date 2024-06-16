class Api::VeggieBotController < ApplicationController
  def build
    @user = User.find_by(discord_id: params['id'])
    if !@user
      render json: {
        error: 'User is not registered with payday charts'
      }, status: 404
      return
    end

    user_stats = PlayerStatGrabber.update_stats_hash(@user.steam_id)
    if !user_stats
      render json: {
        error: "User's stats are not visible to steam. Checking for account with id: #{@user.steam_id}"
      }, status: 404
      return
    end

    weapon_stats = user_stats[0]
    ordered_set = []

    WeaponStat.column_names.filter {|name| name.starts_with?('weapon_kills_') }.each do |stat_name|
      ordered_set << [Localizer.localize(stat_name.gsub('weapon_kills_', 'bm_w_')), weapon_stats[stat_name] || 0]
    end

    ordered_set.sort_by! {|val| val[1] }
    
    render json: {
      weapon_stats: ordered_set
    }
  end

  private

  def blacklist
    %w[
      weapon_kills_x_peacemaker
      weapon_kills_flamethrower_mk3
      weapon_kills_x_lemming
      weapon_kills_groza_underbarrel
      weapon_kills_kacchainsaw_flamethrower
      weapon_kills_type54_underbarrel
      weapon_kills_x_type54_underbarrel
    ]
  end
end