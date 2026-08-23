class DraftBansController < ApplicationController
  before_action :authenticate_user!

  def create
    @draft_ban = DraftBan.new(draft_ban_params)
    @draft_ban.draft_game_user = @draft_ban.draft_game&.draft_game_users&.find_by(user: current_user)
    @draft_ban.save
  end

  private

  def draft_ban_params
    params.require(:draft_ban).permit(
      :name,
      :draft_game_id,
    )
  end
end