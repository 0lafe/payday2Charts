class BasicRackAuth
  def matches?(request)
    steam_id = request.session[:steam_id]

    user = User.find_by(steam_id:)

    user.present? && user.admin?
  end
end