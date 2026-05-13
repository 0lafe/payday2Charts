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

  def top_100
    unless Leaderboard.up?
      render :top_100_maintenance
      return
    end

    steam_id = params[:id].gsub(/\D/, '')
    @leaderboard_user = User.find_by(steam_id:)

    if @leaderboard_user.nil?
      status = PlayerStatGrabber.store_individual(steam_id)
      case status
      when "success"
        @leaderboard_user = User.find_by(steam_id:)
      when "banned"
        redirect_to(top_100_index_leaderboards_path, alert: "User is currently banned") && return
      when false
        redirect_to(top_100_index_leaderboards_path, alert: "Error, make sure the ID is correct and the player's stats are public and try again") && return
      end
    end

    @stats = Leaderboard.user_positions(@leaderboard_user).sort_by { |item| item[:value] }
    @weapon_stats = WeaponStat.find_by(user_id: @leaderboard_user.id)
    @player_stats = PlayerStat.find_by(user_id: @leaderboard_user.id)
    @misc_stats = MiscStat.find_by(user_id: @leaderboard_user.id)
  end

  private

  def handle_grouping
    @filter = ["kills", "used", "shots", "hits"].include?(params[:filter]) && params[:filter] || "kills"

    if params[:id] == "bm_throwable_laser_watch"
      @filter = "used"
    end

    @data = WeaponStat.get_top_100(@name_id, @filter)
    @name = Localizer.localize(@name_id)
  end
end
