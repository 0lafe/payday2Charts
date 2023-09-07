class ApplicationController < ActionController::Base

  def black_list
    [
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
  end

  def get_schema
    response = HTTParty.get("https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=#{ENV['STEAM_KEY']}&appid=218620")
    if response.ok?
      data = JSON.parse(response.body)
      return data
    else
      return {error: response.headers}
    end
  end

  def get_stat_names(stat_type)
    stats = get_schema['game']['availableGameStats']['stats']
    stats = stats.filter {|stat| stat['name'].index(stat_type) == 0 }.map {|stat| stat['name'] }
    stats = stats.filter {|stat| !black_list.include?(stat) }
  end

  def generate_url(type)
    base_url = "https://api.steampowered.com/ISteamUserStats/GetGlobalStatsForGame/v1/?key=#{ENV['STEAM_KEY']}&appid=218620"
    count = 0
    query = ""
    urls = []
    get_stat_names(type).each do |stat|
      if count >= 100
        urls << base_url + "&count=#{count}" + query
        count = 0
        query = ""
      end
      query += "&name[#{count}]=#{stat}"
      count = count + 1
    end
    urls << base_url + "&count=#{count}" + query
    urls
  end

  def get_stats(urls, startdate = nil, enddate = nil)
    data = []
    urls.each do |base_url|
      if startdate && enddate
        data << HTTParty.get("#{base_url}&startdate=#{startdate}&enddate=#{enddate}")
      else
        data << HTTParty.get(base_url)
      end
    end

    out = {'response' => {'globalstats' => {}}}

    data.each do |item|
      begin
        out['response']['globalstats'] = out['response']['globalstats'].merge(item['response']['globalstats'])
      rescue
        return false
      end
    end
    out
  end

  def get_historical_stats(urls, stat)
    data = []
    urls.each do |base_url|
      data << HTTParty.get(base_url)
    end

    # out = {'response' => {'globalstats' => {}}}

    history = []

    data.each do |item|
      begin
        history << item['response']['globalstats'][stat]['history']
        # out['response']['globalstats'] = out['response']['globalstats'].merge(item['response']['globalstats'])
      rescue
        return false
      end
    end
    history
  end

  def long_historical_data(stat)
    base_url = "https://api.steampowered.com/ISteamUserStats/GetGlobalStatsForGame/v1/?key=#{ENV['STEAM_KEY']}&appid=218620&count=1&name[0]=#{stat}"
    urls = []
    30.times do |i|
      origin = (Date.today - (59 * i).days)
      time_1 = (origin - 59.days).to_time.to_i
      time_2 = (origin).to_time.to_i
      urls << base_url + "&startdate=#{time_1}&enddate=#{time_2}"
    end
    get_historical_stats(urls, stat)
  end

  def get_missing_stats
    current_stats = WeaponStat.column_names + PlayerStat.column_names + MiscStat.column_names

    remote_stats = get_schema['game']['availableGameStats']['stats'].map {|s| s['name'] }

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
