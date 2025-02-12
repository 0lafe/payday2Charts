class SteamApi
  @base_url = "https://api.steampowered.com/"

  def self.get(resource, params = {})
    response = HTTParty.get(
      "#{@base_url}#{resource}?key=#{SteamApiKey.current_key}",
      query: params
    )
    if response.code == 429
      SteamApiKey.increment_key
    end
    response
  end
end