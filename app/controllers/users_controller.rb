class UsersController < ApplicationController
  def create
    user = User.find_or_create_by(steam_id: user_params[:steam_id].gsub(/\D/, ''))

    if user.valid?
      if user.banned?
        flash[:alert] = "User is currently banned. Reach out if this seems like an error"
      else
        if user.update_user_stats
          flash[:notice] = "User added successfully"
        else
          flash[:alert] = "Error, make sure the ID is correct and the player's stats are public then try again"
        end
      end
    else
      flash[:alert] = user.errors.full_messages.to_sentence
    end


    if params[:return_to]
      redirect_to params[:return_to], fallback_location: "/"
    else
      redirect_back fallback_location: '/'
    end
  end

  def index; end

  def search
    return unless current_user&.me?

    redirect_to user_path(params[:search][:id])      
  end

  def show
    return unless current_user&.me?
    
    @user = User.find_by(steam_id: params[:id])

    usage_stats = Stat.where(stat_type: "deck_usage")

    @usage = @user.user_stats.includes(:stat).where(stat: usage_stats).order(value: :desc)
  end

  private

  def user_params
    params.require(:user).permit(:steam_id)
  end
end
