class LeaderboardsController < ApplicationController

  def index
    non_stats = [
      'id',
      'user_id',
      'steam_id',
      'created_at',
      'updated_at'
    ]
    ws = WeaponStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    ps = PlayerStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    ms = MiscStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    @options = ws.concat(ps.concat(ms)).filter do |stat|
      !non_stats.include?(stat[1])
    end
  end

  def show
    name = params[:id]
    @data = if name.index('weapon_') == 0 || name.index('melee_') == 0 || name.index('grenade_') == 0
      WeaponStat.get_top_10(name)
    elsif name.index('mask_') == 0 || name.index('suit_') == 0 || name.index('player_') == 0 || name.index('skill_') == 0
      PlayerStat.get_top_10(name)
    else
      MiscStat.get_top_10(name)
    end
    @name = Localizer.localize_from_statistic(name)
  end

  def top_100_index

  end

  def top_100
    @user = User.find_by(steam_id: params[:id])
    return if @user.nil?

    @stats = Leaderboard.user_positions(@user).sort_by { |item| item[:value] }
    @weapon_stats = WeaponStat.find_by(user_id: @user.id)
    @player_stats = PlayerStat.find_by(user_id: @user.id)
    @misc_stats = MiscStat.find_by(user_id: @user.id)
  end
end
