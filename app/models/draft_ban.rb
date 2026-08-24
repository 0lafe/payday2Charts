class DraftBan < ApplicationRecord
  belongs_to :draft_game, touch: true
  belongs_to :draft_game_user

  before_validation :set_draft_type, on: :create

  after_commit :broadcast_updates, on: [:create, :update, :destroy]

  enum :draft_type, {
    heist: 0,
    perkdeck: 1,
    weapon: 2,
  }

  def set_draft_type
    self.draft_type = case draft_game.stage
    when "heist_bans"
      "heist"
    when "perk_bans"
      "perkdeck"
    when "weapon_bans"
      "weapon"
    end
  end

  def broadcast_updates
    case draft_type
    when "heist"
      draft_game.broadcast_replace_to(
        draft_game,
        target: "heist-bans",
        partial: "draft_games/heist_ban_list",
        locals: {
          draft_game: draft_game
        }
      )

      draft_game.broadcast_replace_to(
        draft_game,
        target: "showoff-content",
        partial: "draft_games/showoff/heist_ban",
        locals: {
          draft_ban: self
        }
      )
    when "perkdeck"
      draft_game.broadcast_replace_to(
        draft_game,
        target: "perkdeck-bans",
        partial: "draft_games/perkdeck_ban_list",
        locals: {
          draft_game: draft_game
        }
      )

      draft_game.broadcast_replace_to(
        draft_game,
        target: "showoff-content",
        partial: "draft_games/showoff/perkdeck_ban",
        locals: {
          draft_ban: self
        }
      )
    end
  end
end