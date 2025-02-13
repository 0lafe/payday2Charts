class PlayerStatGrabber
  
  def self.get_fields
    response = SteamApi.get("ISteamUserStats/GetSchemaForGame/v2/", { appid: "218620" })
    if response.ok?
      data = JSON.parse(response.body)
      data['game']['availableGameStats']['stats']
    else
      raise "Steam API Error"
    end
  end

  def self.write_migration
    fields = get_fields

    out_a = []
    out_b = []
    out_c = []

    fields.each do |field|
      name = field['name']
      command = "t.integer :#{name}"
      if name.index('weapon_') == 0 || name.index('melee_') == 0 || name.index('grenade_') == 0
        out_a << command
      elsif name.index('mask_') == 0 || name.index('suit_') == 0 || name.index('player_') == 0 || name.index('skill_') == 0
        out_b << command
      else
        out_c << command
      end
    end
    
    File.open('./migration_weapons.txt', 'w') do |file|
      file.write(out_a.join("\n"))
    end

    File.open('./migration_player.txt', 'w') do |file|
      file.write(out_b.join("\n"))
    end

    File.open('./migration_misc.txt', 'w') do |file|
      file.write(out_c.join("\n"))
    end

  end

  def self.retreive_user_data(id)
    response = SteamApi.get("ISteamUserStats/GetUserStatsForGame/v2/", { appid: "218620", steamid: id })
    if response.ok?
      data = JSON.parse(response.body)
      return data
    else
      return {error: response.headers}
    end
  end

  def self.create_hash(data)
    weapon_stats = {}
    player_stats = {}
    misc_stats = {}

    data.map do |stat|
      name = stat['name']
      if name.index('weapon_') == 0 || name.index('melee_') == 0 || name.index('grenade_') == 0
        weapon_stats[name] = stat['value'].to_i
      elsif name.index('mask_') == 0 || name.index('suit_') == 0 || name.index('player_') == 0 || name.index('skill_') == 0
        player_stats[name] = stat['value'].to_i
      else
        misc_stats[name] = stat['value'].to_i
      end
    end

    [weapon_stats, player_stats, misc_stats]
  end

  def self.store_data(data, user_id)
    weapon_stats, player_stats, misc_stats = create_hash(data)

    weapon_stats[:user_id] = user_id
    player_stats[:user_id] = user_id
    misc_stats[:user_id] = user_id
    
    WeaponStat.create(weapon_stats)
    PlayerStat.create(player_stats)
    MiscStat.create(misc_stats)
  end

  def self.update_stats_hash(id)
    data = retreive_user_data(id)
    if data['error']
      false
    else
      if data['playerstats'] && data['playerstats']['stats']
        create_hash(data['playerstats']['stats'])
      end
    end
  end

  def self.store_user_data(starting_index = 0)
    players = JSON.parse(File.open('./app/services/players.json').read)['players']
    players.each_with_index do |player, index|
      if index >= starting_index
        data = retreive_user_data(player)
        if data['error']
          false
        else
          if data['playerstats'] && data['playerstats']['stats']
            user = User.find_or_create_by(steam_id: player.to_i).id
            store_data(data['playerstats']['stats'], user)
          end
        end
        p "User at index #{index} finished"
      end
    end
  end

  def self.store_individual(id)
    data = retreive_user_data(id)
    if data['error']
      false
    else
      if data['playerstats'] && data['playerstats']['stats']
        user = User.find_by(steam_id: id)
        if !user.present?
          user = User.create(steam_id: id).id
          store_data(data['playerstats']['stats'], user)
        else
          user.fetch_new_stats
        end
        true
      else
        false
      end
    end
  end
end

