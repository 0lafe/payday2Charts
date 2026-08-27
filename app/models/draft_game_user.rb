class DraftGameUser < ApplicationRecord
  belongs_to :user
  belongs_to :draft_game, touch: true

  validate :team_is_not_full

  validates :team, presence: true

  enum :team, {
    team_a: 0,
    team_b: 1
  }

  private

  def team_is_not_full
    if draft_game.draft_game_users.where(team:).count >= draft_game.players_per_team
      errors.add(:team, "is full")
    end
  end
end