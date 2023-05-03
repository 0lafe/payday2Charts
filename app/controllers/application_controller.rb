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
    # getMissingStats(stats)
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
        byebug
      end
    end
    out
  end

  def getMissingStats(stats)
    options = HomesController.new.index

    additional_filters = [
      'contract_',
      'player_specialization',
      'option_',
      'level_',
      'job_'
    ]
    
    names = stats.map {|stat| stat['name'] }

    options.map {|option| option[1] }.each do |option|
      names = names.filter {|name| !name.include?(option) }
    end

    additional_filters.each do |filter|
      names = names.filter {|name| !(name.index(filter) == 0) }
    end

    byebug
  end

end
