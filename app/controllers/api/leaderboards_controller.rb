class Api::LeaderboardsController < ApplicationController
  before_action :check_lb_up

  before_action :check_api_key

  def index
    @json = Leaderboard.top_100s

    @json.transform_keys! do |stat_ids|
      stat_id_lookup[stat_ids.to_i]
    end

    @json.each_value do |lb|
      lb.each do |user_stat|
        user_stat[0] = user_id_lookup[user_stat[0].to_i]
      end
    end

    render json: @json
  end

  private

  def check_lb_up
    unless Leaderboard.up?
      render json: {
        error: "Leaderboard is not currently up"
      }, status: 404
    end
  end

  def check_api_key
    unless params.require(:api_key) == Rails.application.credentials.public_api_key
      render json: {
        error: "Invalid API Key"
      }, status: :unauthorized
    end
  end

  def user_ids
    @json.values.flatten(1).map(&:first)
  end

  def user_id_lookup
    @user_id_lookup ||= Rails.cache.fetch("user_id_lookup", expires_in: 1.day) do
      User.where(id: user_ids).pluck(:id, :steam_id).to_h
    end
  end

  def stat_id_lookup
    @stat_id_lookup ||= Rails.cache.fetch("stat_id_lookup", expires_in: 1.day) do
      Stat.where(id: @json.keys).pluck(:id, :name).to_h
    end
  end
end
