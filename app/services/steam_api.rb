class SteamApi
  @base_url = "https://api.steampowered.com/"

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
    response
  end

  def self.get_schema
    response = get("ISteamUserStats/GetSchemaForGame/v2/", { appid: "218620" })
    if response.ok?
      data = JSON.parse(response.body)
      return data
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
    stats = get_schema['game']['availableGameStats']['stats']

    stats = stats.filter do |stat|
      stat['name'].starts_with?(@stat_type) && !@blacklist.include?(stat["name"])
    end

    stats.map do |stat|
      stat['name']
    end
  end

  def self.generate_urls
    @queries = []
    get_stat_names().each_slice(100) do |stat_list|
      params = {
        appid: 218620,
        count: stat_list.length,
        startdate: (Date.today - 59.days).to_time.to_i,
        enddate: Date.today.to_time.to_i
      }
      stat_list.each_with_index do |stat, index|
        params["name[#{index}]"] = stat
      end
      @queries << params
    end
  end

  def self.get_stats
    out = {'response' => {'globalstats' => {}}}
    @queries.each do |query|
      response = get("ISteamUserStats/GetGlobalStatsForGame/v1/", query)
      if response.ok?
        out['response']['globalstats'] = out['response']['globalstats'].merge(
          response["response"]["globalstats"]
        )
      else
        raise "Error #{response.status} #{response.body}"
      end
    end
    out
  end

  def self.get_missing_stats
    current_stats = WeaponStat.column_names + PlayerStat.column_names + MiscStat.column_names

    remote_stats = get_schema['game']['availableGameStats']['stats'].map { |s| s['name'] }

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
end