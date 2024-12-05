class GuessWhosController < ApplicationController
  def index; end

  def create
    game = GuessWho.create(guess_who_params)
    if game.valid?
      redirect_to guess_who_path(game)
    else
      redirect_back alert: game.errors.full_messages.to_sentence, fallback_location: root_url
    end
  end

  def show
    @guess_who = GuessWho.find_by_id(params[:id])
    unless @guess_who
      redirect_back alert: "Game does not exist", fallback_location: root_url
    end
  end

  private

  def guess_who_params
    params.require(:guess_who).permit(:game_type)
  end
end