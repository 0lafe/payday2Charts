class LeaderboardsController < ApplicationController

  def index; end

  def show
    obtain_stat

    @user_stats = UserStat
      .joins(:user)
      .where(stat: @stat, user: { banned: false })
      .includes(:user)
      .order(value: :desc)
      .limit(100)

    obtain_other_user_stats if @stat.grouping?

    names = SteamApi.get_multiple_user_data(
      @user_stats.map { |stat|
        stat.user.steam_id
      }
    )

    @user_stats.each_with_index do |stat, index|
      stat.user.steam_name = names[index][:name]
      stat.user.steam_avatar = names[index][:avatar]
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
      @leaderboard_user = User.create(steam_id:)

      unless @leaderboard_user.valid?
        redirect_to(
          leaderboards_path,
          alert: @leaderboard_user.errors.full_messages.to_sentence
        ) && return
      end

      unless @leaderboard_user.update_user_stats
        redirect_to(
          leaderboards_path,
          alert: "Error, make sure the ID is correct and the player's stats are public and try again"
        ) && return
      end
    else
      if @leaderboard_user.banned?
        redirect_to(
          leaderboards_path,
          alert: "User is currently banned"
        ) && return
      end
    end

    @stats = Leaderboard.user_positions(@leaderboard_user)
    @user_stats = @leaderboard_user.user_stats.group_by(&:stat_id)
  end

  private

  def obtain_stat
    @filter = ["kills", "used", "shots", "hits"].include?(params[:filter]) && params[:filter] || "kills"

    if params[:id] == "bm_throwable_laser_watch"
      @filter = "used"
    end

    if @filter
      @stat = Stat.from_internal_name(params[:id], @filter)
    else
      @stat = Stat.find_by(name: params[:id])
    end
  end

  def obtain_other_user_stats
    stat_prefixes = if @stat.weapon?
      ["kills", "used", "shots", "hits"] - [@filter]
    else
      ["kills", "used"] - [@filter]
    end

    stat_names = @stat.other_grouped_stats(stat_prefixes)

    user_ids = @user_stats.map(&:user_id)

    extra_stats = UserStat.joins(:stat)
      .where(
        user_id: user_ids,
        stats: {
          name: stat_names
        }
      )
      .includes(:stat)

    @extra_stats_lookup =
      extra_stats.group_by(&:user_id).transform_values do |stats|
        stats.to_h do |stat|
          key = if stat.stat.name.include?("_kills_")
            "kills"
          elsif stat.stat.name.include?("_used_")
            "used"
          elsif stat.stat.name.include?("_shots_")
            "shots"
          elsif stat.stat.name.include?("_hits_")
            "hits"
          end

          [
            key,
            stat.value
          ]
        end
      end
  end
end
