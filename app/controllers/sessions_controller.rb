class SessionsController < ApplicationController
  def index
    identity = params["openid.identity"]
    steam_id = identity && identity.gsub("https://steamcommunity.com/openid/id/", "")
    session[:steam_id] = steam_id
    redirect_to root_path, notice: "Logged In Successfully"
  end

  def new; end

  def destroy
    session[:steam_id] = nil
    redirect_to root_path, alert: "Logged Out Successfully"
  end
end