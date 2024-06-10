class OauthController < ApplicationController
  def index
    begin
      client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], site: 'https://discord.com', authorization_url: '/oauth2/authorize', token_url: '/api/oauth2/token')
      access = client.auth_code.get_token(params['code'], redirect_uri: 'https://payday-2-charts.herokuapp.com/oauth')
      token = access.token
    rescue
      @error = 'OAuth flow failed'
      render :index
    end

    response = HTTParty.get(
      'https://discord.com/api/users/@me/connections',
      headers: {
        'Authorization': "Bearer #{token}"
      }
    )

    reply = JSON.parse(response.body)

    steam_account = reply.filter {|acc| acc['type'] && acc['type'] == 'steam' }.first
    if !steam_account
      @error = 'No Steam account connected to your discord account'
      render :index && return
    end

    user = User.find_by(steam_id: steam_account['id'])
    if !user
      @error = 'Your steam account is not linked to this website. Link it <a href="/leaderboards">here</a>'
      render :index && return
    end

    response = HTTParty.get(
      'https://discord.com/api/users/@me',
      headers: {
        'Authorization': "Bearer #{token}"
      }
    )

    discord_id = JSON.parse(response.body)['id']

    user.update(discord_id:)
  end
end
