class DraftPick < ApplicationRecord
  belongs_to :draft_game, touch: true
  belongs_to :draft_game_user

  before_validation :set_draft_type, :set_draft_target, on: :create

  validate :is_their_turn

  validates :name, :draft_type, :draft_target, presence: true

  after_commit :broadcast_updates, on: [:create, :update, :destroy]

  enum :draft_type, {
    ban: 0,
    choice: 1,
  }

  enum :draft_target, {
    heist: 0,
    perkdeck: 1,
    weapon: 2,
    skill: 3,
  }

  def set_draft_type
    self.draft_type = case draft_game.stage
    when "perk_choices", "weapon_choices"
      "choice"
    when "perk_bans", "weapon_bans", "heist_bans", "skill_bans"
      "ban"
    end
  end

  def set_draft_target
    self.draft_target = case draft_game.stage
    when "heist_bans"
      "heist"
    when "perk_bans", "perk_choices"
      "perkdeck"
    when "weapon_bans", "weapon_choices"
      "weapon"
    when "skill_bans"
      "skill"
    end
  end

  def image
    case draft_target
    when "heist"
      ActionController::Base.helpers.asset_path("heists/named/#{name}.png")
    when "perkdeck"
      ActionController::Base.helpers.asset_path("perkdecks/#{name}.png")
    when "weapon"
      ActionController::Base.helpers.asset_path("weapon_types/#{name}.png")
    when "skill"
      ActionController::Base.helpers.asset_path("skill_trees/#{name}.png")
    end
  end

  def sound
    if ban?
      ActionController::Base.helpers.asset_path("Ban.mp3")
    else
      ActionController::Base.helpers.asset_path("Selection.mp3")
    end
  end

  def broadcast_updates
    draft_game.broadcast_update_to(
      draft_game,
      target: "showoff-area",
      partial: "draft_games/showoff/#{draft_target}",
      locals: {
        draft_pick: self
      }
    )
  end

  private

  def is_their_turn
    unless draft_game_user.user == draft_game.current_turn_user
      errors.add(:draft_game, "is not your turn")
    end
  end
end