class AdvanceDraftGameHeistSelectJob < ApplicationJob

  def perform(id)
    draft_game = DraftGame.find(id)

    draft_game.set_heist

    AdvanceDraftGamePerkBanJob
      .set(wait: 5.second)
      .perform_later(id)
  end
end
