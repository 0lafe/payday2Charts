class JeopardyPlayersController < ApplicationController
  def update
    @player = JeopardyPlayer.find(params[:id])
    @player.update(player_params)
    @game = @player.jeopardy_game
  end

  private

  def player_params
    params.require(:jeopardy_player).permit(:score)
  end
end