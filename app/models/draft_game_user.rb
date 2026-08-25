class DraftGameUser < ApplicationRecord
  belongs_to :user
  belongs_to :draft_game, touch: true

  enum :team, {
    team_a: 0,
    team_b: 1
  }
end