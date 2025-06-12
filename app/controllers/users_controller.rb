class UsersController < ApplicationController
  def create
    result = PlayerStatGrabber.store_individual(params[:user][:steam_id].gsub(/\D/, ''))
    if result == "success"
      flash[:notice] = "User added successfully"
    elsif result == "banned"
      flash[:warning] = "User is currently banned. Reach out if this seems like an error"
    else
      flash[:alert] = "Error, make sure the ID is correct and the player's stats are public and try again"
    end
    if params[:return_to]
      redirect_to params[:return_to], fallback_location: "/"
    else
      redirect_back fallback_location: '/'
    end
  end

  private

  def user_params
    params.require(:user).permit(:steam_id)
  end
end