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

  def broadcast_updates
    case draft_target
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
          draft_pick: self
        }
      )
    when "perkdeck"
      if ban?
        draft_game.broadcast_replace_to(
          draft_game,
          target: "perkdeck-bans",
          partial: "draft_games/perkdeck_ban_list",
          locals: {
            draft_game: draft_game
          }
        )
      else
        
      end

      draft_game.broadcast_replace_to(
        draft_game,
        target: "showoff-content",
        partial: "draft_games/showoff/perkdeck_pick",
        locals: {
          draft_pick: self
        }
      )
    end
  end
end