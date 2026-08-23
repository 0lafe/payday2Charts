class DraftGameChannel < ApplicationCable::Channel
  def subscribed
    draft_game = DraftGame.find_by!(public_key: params[:id])

    stream_for draft_game
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
