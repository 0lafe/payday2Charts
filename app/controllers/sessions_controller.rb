require "openid"
require "openid/extensions/sreg"
require "openid/extensions/pape"
require "openid/store/filesystem"

class SessionsController < ApplicationController
  def redirect_to_steam
    oidreq = consumer.begin("https://steamcommunity.com/openid")
    return_to = process_openid_return_sessions_url
    realm = root_url

    if oidreq.send_redirect?(realm, return_to)
      redirect_to(oidreq.redirect_url(realm, return_to), allow_other_host: true)
    end
  end

  def process_openid_return
    current_url = process_openid_return_sessions_url
    parameters = params.reject { |k, _v| request.path_parameters[k] }
    parameters.reject! { |k, _v| %w[action controller].include?(k.to_s) }
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
    when OpenID::Consumer::FAILURE
      redirect_to new_sessions_path, alert: "Verification failed please try again"
    when OpenID::Consumer::SUCCESS
      identity = params.require("openid.identity")
      @steam_id = identity&.gsub("https://steamcommunity.com/openid/id/", "")
      session[:steam_id] = @steam_id
      create_if_new_user

      redirect_to root_path, notice: "Logged In Successfully"
    else
      redirect_to new_sessions_path, alert: "Something went wrong in the login process. Please try again"
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

  def consumer
    if @consumer.nil?
      dir = Rails.root.join("tmp", "openid")
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    @consumer
  end
end