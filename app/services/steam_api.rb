class SteamApi
  @base_url = "https://api.steampowered.com/"

  @schema ||= JSON.parse(File.open("./app/services/steam_stat_schema.json").read)

  @blacklist = [
    'weapon_kills_tec9',
    'grenade_kills_wpn_prj_ace',
    'suit_used_poolrepair_default',
    'weapon_shots_model70',
    'weapon_shots_x_p226',
    'weapon_shots_x_rage',
    'weapon_shots_x_uzi',
    'weapon_hits_x_akmsu',
    'weapon_hits_tecci',
    'weapon_hits_breech',
    'weapon_hits_tti',
    'weapon_hits_x_m45',
    'weapon_hits_coach',
    'player_time',
    'player_rank',
    'player_cash',
    'player_level',
    'player_coins',
    'skill_hoxton',
    'skill_chains',
    'skill_wolf',
    'skill_dallas',
    'skill_houston',
    'skill_mastermind',
    'skill_enforcer',
    'skill_ghost',
    'skill_technician',
    'skill_fugative'
  ]

  def self.get(resource, params = {})
    response = HTTParty.get(
      "#{@base_url}#{resource}?key=#{SteamApiKey.current_key}",
      query: params
    )
    if response.code == 429
      SteamApiKey.increment_key
    end
    ApiLog.create(resource:, params:, code: response.code)
    response
  end

  def self.schema
    @schema
  end

  def self.update_schema
    response = get("ISteamUserStats/GetSchemaForGame/v2/", { appid: "218620" })
    if response.ok?
      File.open("./app/services/steam_stat_schema.json", "w") do |file|
        file.write(
          JSON.parse(response.body)['game']['availableGameStats']['stats'].to_json
        )
      end
    else
      raise "Error #{response.status} #{response.body}"
    end
  end

  def self.retrieve_stats(stat_type)
    @stat_type = stat_type
    generate_urls
    get_stats
  end

  def self.get_stat_names
    stats = @schema.filter do |stat|
      stat['name'].starts_with?(@stat_type) && !@blacklist.include?(stat["name"])
    end

    stats.map do |stat|
      stat['name']
    end
  end

  def self.generate_urls
    @queries = get_stat_names().each_slice(100).map do |stat_list|
      params = {
        appid: 218620,
        count: stat_list.length,
        startdate: (Date.today - 59.days).to_time.to_i,
        enddate: Date.today.to_time.to_i
      }
      stat_list.each_with_index.reduce(params) do |params, (stat, index)|
        params.update("name[#{index}]": stat)
      end
    end
  end

  def self.get_stats
    @queries.reduce({}) do |data, query|
      response = get("ISteamUserStats/GetGlobalStatsForGame/v1/", query)
      if response.ok?
        data.merge(
          response["response"]["globalstats"]
        )
      else
        raise "Error #{response.status} #{response.body}"
      end
    end
  end

  def self.get_missing_stats
    current_stats = WeaponStat.column_names + PlayerStat.column_names + MiscStat.column_names

    remote_stats = @schema.map do |s|
      s['name']
    end

    diff = remote_stats - current_stats

    formatted_diff = diff.map do |stat|
      {'name' => stat}
    end

    weapon_stats, player_stats, misc_stats = PlayerStatGrabber.create_hash(formatted_diff)

    weapon_stats.keys.each do |key|
      p "add_column :weapon_stats, :#{key}, :integer"
    end

    p ""

    player_stats.keys.each do |key|
      p "add_column :player_stats, :#{key}, :integer"
    end

    p ""

    misc_stats.keys.each do |key|
      p "add_column :misc_stats, :#{key}, :integer"
    end
  end

  def self.get_multiple_user_data(user_ids)
    cached_data = get_cached_user_data(user_ids)
    existing_data = {}
    missing_ids = []
  
    user_ids.each_with_index do |id, index|
      if cached_data[index]
        existing_data[id] = JSON.parse(cached_data[index], symbolize_names: true)
      else
        missing_ids << id
      end
    end

    if missing_ids.present?
      response = get(
        "ISteamUser/GetPlayerSummaries/v2/",
        {
          steamids: missing_ids.join(',')
        }
      )

      new_data = if response.ok?
        data = JSON.parse(response.body)
        data['response']['players'].map do |player|
          {
            name: player['personaname'],
            avatar: player["avatar"],
            steam_id: player["steamid"]
          }
        end
      else
        missing_ids.map do |user_id|
          missing_data_profile(user_id)
        end
      end

      missing_ids.each do |missing_id|
        unless new_data.any? { |data| data[:steam_id] == missing_id }
          new_data << missing_data_profile(missing_id)
        end
      end
      
      # # Uncomment when disabling API requests
      # new_data = missing_ids.map do |user_id|
      #   missing_data_profile(user_id)
      # end

      new_data.each do |user_data|
        REDIS_CLIENT.setex("steam_player_summary:#{user_data[:steam_id]}", 48.hours.to_i, user_data.to_json)
        existing_data[user_data[:steam_id]] = user_data
      end
    end

    vals = user_ids.map do |user_id|
      existing_data[user_id]
    end

    vals
  end

  def self.get_cached_user_data(user_ids)
    keys = user_ids.map { |id| "steam_player_summary:#{id}" }
    REDIS_CLIENT.mget(*keys)
  end

  def self.get_user_data(steam_id)
    cached_data = REDIS_CLIENT.get("steam_player_summary:#{steam_id}")

    if cached_data
      JSON.parse(cached_data, symbolize_names: true)
    else
      response = SteamApi.get(
        "ISteamUser/GetPlayerSummaries/v2/",
        {
          steamids: steam_id
        }
      )

      new_data = if response.ok?
        data = JSON.parse(response.body)
        user_data = data['response']['players'].first
        {
          name: user_data['personaname'],
          avatar: user_data["avatar"],
          steam_id: user_data["steamid"]
        }
      else
        missing_data_profile(steam_id)
      end

      # # Uncomment when disabling API requests
      # new_data = missing_data_profile(steam_id)

      REDIS_CLIENT.setex("steam_player_summary:#{steam_id}", 48.hours.to_i, new_data.to_json)

      new_data
    end
  end

  def self.missing_data_profile(steam_id)
    {
      name: steam_id,
      avatar: "https://fbi-files.s3.us-east-1.amazonaws.com/steam_logo.png",
      steam_id: steam_id
    }
  end
end