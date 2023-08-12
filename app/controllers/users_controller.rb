class UsersController < ApplicationController
  def create
    if PlayerStatGrabber.store_individual(params[:user][:steam_id].gsub(' ', ''))
      flash[:notice] = "User added successfully"
    else
      flash[:alert] = "Error, make sure the ID is correct and the player's stats are public and try again"
    end
    redirect_back fallback_location: '/'
  end

  private

  def user_params
    params.require(:user).permit(:steam_id)
  end
end