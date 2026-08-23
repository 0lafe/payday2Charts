class DraftGameUser < ApplicationRecord
  belongs_to :user
  belongs_to :draft_game

  enum :team, {
    team_a: 0,
    team_b: 1
  }

  after_commit :broadcast_updates, on: [:create, :update, :destroy]
  after_commit :remove_waiting, on: [:create, :update, :destroy]

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

  def remove_waiting
    if draft_game.full?
      draft_game.update(stage: 1)

      draft_game.update_interaction_area
    end
  end
end