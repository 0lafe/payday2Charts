class DraftBan < ApplicationRecord
  belongs_to :draft_game
  belongs_to :draft_game_user
end