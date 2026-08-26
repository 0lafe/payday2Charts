class AdvanceDraftGamePerkBanJob < ApplicationJob

  def perform(id)
    draft_game = DraftGame.find(id)

    draft_game.update(stage: "perk_bans")

    draft_game.update_interaction_area
  end
end
