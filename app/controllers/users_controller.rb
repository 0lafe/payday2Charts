class UsersController < ApplicationController
  def create
    user = User.find_or_create_by(steam_id: user_params[:steam_id].gsub(/\D/, ''))

    if user.banned?
      flash[:alert] = "User is currently banned. Reach out if this seems like an error"
    else
      if user.update_user_stats
        flash[:notice] = "User added successfully"
      else
        flash[:alert] = "Error, make sure the ID is correct and the player's stats are public then try again"
      end
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
