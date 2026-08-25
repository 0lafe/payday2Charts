class DraftPick < ApplicationRecord
  belongs_to :draft_game, touch: true
  belongs_to :draft_game_user

  before_validation :set_draft_type, :set_draft_target, on: :create

  after_commit :broadcast_updates, on: [:create, :update, :destroy]

  enum :draft_type, {
    ban: 0,
    choice: 1,
  }

  enum :draft_target, {
    heist: 0,
    perkdeck: 1,
    weapon: 2,
  }

  def set_draft_type
    self.draft_type = case draft_game.stage
    when "perk_choices", "weapon_choices"
      "choice"
    when "perk_bans", "weapon_bans", "heist_bans"
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
    end
  end

  def broadcast_updates
    draft_game.broadcast_replace_to(
      draft_game,
      target: "showoff-content",
      partial: "draft_games/showoff/#{draft_target}",
      locals: {
        draft_pick: self
      }
    )
  end
end