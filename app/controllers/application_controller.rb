class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= get_current_user
  end

  def get_current_user
    if session[:steam_id]
      User.find_by(steam_id: session[:steam_id])
    end
  end

  def authenticate_user!
    return if current_user

    redirect_to new_session_path, alert: "You must be logged in to access this page."
  end
end
