class SessionsController < ApplicationController
  def index
    identity = params["openid.identity"]
    steam_id = identity && identity.gsub("https://steamcommunity.com/openid/id/", "")
  end

  def new; end
end