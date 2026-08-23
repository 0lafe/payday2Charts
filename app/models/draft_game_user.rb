class DraftGameUser < ApplicationRecord
  belongs_to :user
  belongs_to :draft_game, touch: true

  enum :team, {
    team_a: 0,
    team_b: 1
  }

  after_commit :broadcast_updates, on: [:create, :update, :destroy]

  def broadcast_updates
    draft_game.broadcast_replace_to(
      draft_game,
      target: team,
      partial: "draft_games/team_list",
      locals: {
        draft_game: draft_game,
        team: team
      }
    )
  end
end