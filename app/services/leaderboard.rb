class Leaderboard
  attr_accessor :updated_at, :top_100s
  def initialize
    @top_100s = {}
    [WeaponStat, PlayerStat, MiscStat].each do |stat|
      p "Storing #{stat} in leaderboard"
      store_top_100s(stat)
    end
    @updated_at = Time.now.to_formatted_s(:short)
  end

  def self.create
    lb = Leaderboard.new
    return {
      updated_at: lb.updated_at,
      top_100s: lb.top_100s
    }
  end

  def self.read
    JSON.parse(REDIS_CLIENT.get('lb'))
  end

  def store_top_100s(table)
    i = 1
    max = table.column_names.length
    @top_100s[table.name.underscore] = table.column_names.map do |column|
      p "Working on #{i} out of #{max}"
      i += 1
      {
        name: column,
        values: table.where.not({column => nil}).order("#{column} DESC").limit(100).pluck(:user_id)
      }
    end
    @top_100s[table.name.underscore].filter! do |stat|
      !blacklist_single().include?(stat[:name])
    end
    blacklist_multiple().each do |blacklisted_stat|
      @top_100s[table.name.underscore].filter! do |stat|
        !stat[:name].start_with?(blacklisted_stat)
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
      'specialization_',
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
