class DraftPicksController < ApplicationController
  before_action :authenticate_user!

  def create
    @draft_pick = DraftPick.new(draft_pick_params)
    @draft_pick.draft_game_user = @draft_pick.draft_game&.draft_game_users&.find_by(user: current_user)
    @draft_pick.save
  end

  private

  def draft_pick_params
    params.require(:draft_pick).permit(
      :name,
      :draft_game_id,
    )
  end
end