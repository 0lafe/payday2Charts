class SteamApiKey
  def self.current_key
    current_index = REDIS_CLIENT.get("steam_key_index")

    # set initial key
    if current_index.nil?
      REDIS_CLIENT.set("steam_key_index", "a")
      current_index = "a"
    end

    Rails.application.credentials.steam[current_index]
  end

  def self.increment_key
    new_index = REDIS_CLIENT.get("steam_key_index").next
    if Rails.application.credentials.steam[new_index]
      REDIS_CLIENT.set("steam_key_index", new_index)
    else
      REDIS_CLIENT.set("steam_key_index", "a")
    end
  end
end