module ApplicationHelper
  def current_user
    @current_user ||= get_current_user
  end

  def get_current_user
    if session[:steam_id]
      User.find_by(steam_id: session[:steam_id])
    end
  end

  def notification_banners
    Rails.cache.fetch("notification_banners", expires_in: 1.hour) do
      NotificationBanner.all
    end
  end
end
