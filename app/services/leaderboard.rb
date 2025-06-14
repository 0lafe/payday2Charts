class Leaderboard
  attr_accessor :updated_at, :top_100s, :usernames
  def initialize
    @top_100s = {}
    [WeaponStat, PlayerStat, MiscStat].each do |stat|
      p "Storing #{stat} in leaderboard"
      store_top_100s(stat)
    end
    @updated_at = Time.now.to_formatted_s(:short)
    # get_user_names
  end

  def get_user_names
    names = []
    ['weapon_stat', 'player_stat', 'misc_stat'].each do |type|
      @top_100s[type].each do |stat|
        user_id = stat[:values].first
        if user_id
          names << user_id
        end
      end
    end
    names.uniq!

    users = User.where(id: names)
    @usernames = {}
    users.each_slice(100) do |users|
      steam_data = SteamApi.get_multiple_user_data(users.map(&:steam_id))
      users.each_with_index do |user, index|
        @usernames[user.steam_id] = steam_data[index][:name]
      end
    end
  end

  def self.create
    lb = Leaderboard.new
    return {
      updated_at: lb.updated_at,
      top_100s: lb.top_100s,
      usernames: lb.usernames
    }
  end

  def self.read
    JSON.parse(REDIS_CLIENT.get('lb'))
  end

  def store_top_100s(table)
    first_filter = table.column_names.filter do |col|
      !blacklist_single().include?(col)
    end

    second_filter = first_filter.filter do |col|
      !blacklist_multiple().any? do |blacklist_stub|
        col.starts_with?(blacklist_stub)
      end
    end

    ActiveRecord::Base.connection.unprepared_statement do
      @top_100s[table.name.underscore] = second_filter.each_with_index.map do |column, i|
        GC.start if i % 100 == 0
        p "Working on #{i + 1} out of #{second_filter.length}"
        {
          name: column,
          values: table.joins(:user).where.not(user: { banned: true }).where.not({column => nil}).order("#{column} DESC").limit(100).select(:user_id).pluck(:user_id)
        }
      end
    end
  end

  def self.user_positions(user)
    user_id = user.id
    out = []
    ['weapon_stat', 'player_stat', 'misc_stat'].each do |type|
      filtered = Leaderboard.read['top_100s'][type].filter do |stat|
        stat['values'].include?(user_id)
      end
      filtered.each do |stat|
        out << {
          name: stat['name'],
          value: stat['values'].index(user_id)
        }
      end
    end
    out
  end

  def self.ranked_users
    users = User.where(id: @ranked_list.map {|a| a[0] })
    @rankings = users.map do |user|
      {
        steam_id: user.steam_id,
        count: @ranked_list[user.id],
        username: @data["usernames"][user.steam_id]
      }
    end
  end

  def self.ranked_list
    @data = read
    @ranked_list = {}
    ['weapon_stat', 'player_stat', 'misc_stat'].each do |type|
      @data["top_100s"][type].each do |stat|
        user_id = stat["values"].first
        if user_id
          if @ranked_list[user_id]
            @ranked_list[user_id] = @ranked_list[user_id] + 1
          else
            @ranked_list[user_id] = 1
          end
        end
      end
    end
  end

  def self.rankings
    ranked_list
    ranked_users
    @rankings.sort_by { |user| user[:count] }.reverse
  end

  def formatted_positions(user)
    user_positions.map do |stat|
      "User is ##{stat[:value] + 1} for #{Localizer.localize_from_statistic(stat[:name])}"
    end
  end

  def blacklist_single
    [
      'id',
      'user_id',
      'created_at',
      'updated_at',
      'tester',
      'story_menu_skip',
      'payday2'
    ]
  end

  def blacklist_multiple
    [
      'stat_',
      'option_',
      'player_',
      'skill_',
      'setting_',
      'sb17_',
      'pda_',
      'pim_',
      'pxp1_',
      'main_menu_',
      'info_playing_',
      'equipped_',
      'pxp2_',
      'cac_'
    ]
  end
end
