class SessionsController < ApplicationController
  def index
    identity = params["openid.identity"]
    if identity
      @steam_id = identity && identity.gsub("https://steamcommunity.com/openid/id/", "")
      session[:steam_id] = @steam_id
      create_if_new_user
      redirect_to root_path, notice: "Logged In Successfully"
    else
      redirect_to root_path, alert: "Failed To Log In"
    end
  end

  def new; end

  def destroy
    session[:steam_id] = nil
    redirect_to root_path, alert: "Logged Out Successfully"
  end

  private

  def create_if_new_user
    User.find_or_create_by(steam_id: @steam_id)
  end
end