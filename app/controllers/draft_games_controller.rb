class DraftGamesController < ApplicationController
  before_action :authenticate_user!, except: [:stream_header, :stream_footer]

  before_action :set_draft_game, only: [:show, :join_team, :stream_header, :stream_footer, :team_win]

  def show; end

  def new
    @heists = JSON.parse(File.read("./app/models/concerns/heists.json"))
    @weapon_types = JSON.parse(File.read("./app/models/concerns/weapon_types.json"))
    @perkdecks = JSON.parse(File.read("./app/models/concerns/perkdecks.json"))
    @skill_trees = JSON.parse(File.read("./app/models/concerns/skill_trees.json"))
  end

  def create
    new_game = DraftGame.new(draft_game_params)
    new_game.user = current_user
    new_game.save

    redirect_to new_game
  end

  def join_team
    team = params[:team]

    unless %w[team_a team_b].include?(team)
      return head :unprocessable_entity
    end

    @new_user = DraftGameUser.create(
      user: current_user,
      draft_game: @draft_game,
      team:
    )
  end

  def stream_header; end

  def stream_footer; end

  def team_win
    unless current_user == @draft_game.user
      return redirect_back alert: "Only the host can select a winner", fallback_location: root_url
    end

    team = params[:team]

    unless %w[team_a team_b].include?(team)
      return head :unprocessable_entity
    end

    @draft_game.add_win(team)
  end

  private

  def draft_game_params
    params.require(:draft_game).permit(
      :heist_ban_count,
      :perkdeck_ban_count,
      :weapon_ban_count,
      :skill_ban_count,
      :players_per_team,
      :round_count,
      base_heists: [],
      base_perkdecks: [],
      base_weapons: [],
      base_skills: [],
    )
  end

  def set_draft_game
    @draft_game = DraftGame.find_by!(public_key: params[:id])
  end
end