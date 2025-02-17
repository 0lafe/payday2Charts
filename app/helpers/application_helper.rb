module ApplicationHelper
  def current_user
    @user ||= get_current_user
  end

  def get_current_user
    if session[:steam_id]
      User.find_by(steam_id: session[:steam_id])
    end
  end
end
