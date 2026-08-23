class DraftGamesController < ApplicationController
  before_action :authenticate_user!

  def show
    @draft_game = DraftGame.find_by(public_key: params[:id])
  end

  def new
    @heists = JSON.parse(File.read("./app/models/concerns/heists.json"))['data'].sort
    @weapon_types = JSON.parse(File.read("./app/models/concerns/weapon_types.json"))['data'].sort
    @perkdecks = JSON.parse(File.read("./app/models/concerns/perkdecks.json"))['data'].sort
  end

  def create
    newGame = DraftGame.new(draft_game_params)
    newGame.user = current_user
    newGame.save

    redirect_to newGame
  end

  def join_team
    @draft_game = DraftGame.find_by(public_key: params[:id])

    team = params[:team]

    unless %w[team_a team_b].include?(team)
      return head :unprocessable_entity
    end

    @new_user = DraftGameUser.create(
      user: current_user,
      draft_game: @draft_game,
      team:
    )

    if @new_user.valid?
      render turbo_stream: turbo_stream.replace(
        "interaction-area",
        partial: "draft_games/interaction_area",
        locals: {
          draft_game: @draft_game,
          user: current_user
        }
      )
    end
  end

  private

  def draft_game_params
    params.require(:draft_game).permit(
      :heist_ban_count,
      :perkdeck_ban_count,
      :weapon_ban_count,
      base_heists: [],
      base_perkdecks: [],
      base_weapons: []
    )
  end
end