class AdvanceDraftGamePerkBanJob < ApplicationJob

  def perform(id)
    draft_game = DraftGame.find(id)

    draft_game.update(stage: "perk_bans")

    draft_game.broadcast_replace_to(
      draft_game,
      target: 'showoff-content',
      html: '<div id="showoff-content"></div>'
    )

    draft_game.update_interaction_area
  end
end
