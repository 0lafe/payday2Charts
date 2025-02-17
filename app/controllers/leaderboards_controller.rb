class LeaderboardsController < ApplicationController

  def index; end

  def show
    @name_id = params[:id]
    @grouping = ["weapon", "melee", "throwable"].include?(params[:grouping]) && params[:grouping] || nil
    if @grouping
      handle_grouping
    else
      @data = if @name_id.index('weapon_') == 0 || @name_id.index('melee_') == 0 || @name_id.index('grenade_') == 0
        WeaponStat.get_top_100(@name_id)
      elsif @name_id.index('mask_') == 0 || @name_id.index('suit_') == 0 || @name_id.index('player_') == 0 || @name_id.index('skill_') == 0
        PlayerStat.get_top_100(@name_id)
      else
        MiscStat.get_top_100(@name_id)
      end
      @name = Localizer.localize_from_statistic(@name_id)
    end
  end

  def top_100_index
  end

  def top_100
    @user = User.find_by(steam_id: params[:id].gsub(/\D/, ''))
    return if @user.nil?

    @stats = Leaderboard.user_positions(@user).sort_by { |item| item[:value] }
    @weapon_stats = WeaponStat.find_by(user_id: @user.id)
    @player_stats = PlayerStat.find_by(user_id: @user.id)
    @misc_stats = MiscStat.find_by(user_id: @user.id)
  end

  private

  def handle_grouping
    @filter = ["kills", "used", "shots", "hits"].include?(params[:filter]) && params[:filter] || "kills"
    @data = WeaponStat.get_top_100(@name_id, @filter)
    @name = Localizer.localize(@name_id)
  end
end
