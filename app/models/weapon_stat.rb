class WeaponStat < ApplicationRecord
  belongs_to :user

  def self.get_top_10(name)
    users = WeaponStat.where.not({name => nil}).order("#{name} DESC").includes(:user).limit(100)
    names = User.names(users.map {|player| player.user.steam_id })
    users.map.with_index do |a, index|
      {
        name: names[index],
        steam_id: a.user.steam_id,
        value: a[name],
        updated_at: a.updated_at
      }
    end
  end

  def self.lowest_kills
    kill_stats = column_names.filter do |name|
      name.index('weapon_kills_') == 0
    end

    values = kill_stats.map do |stat|
      val = WeaponStat.where.not({stat => nil}).order("#{stat} DESC").first
      if val.present?
        [stat, val[stat]]
      else
        [stat, 0]
      end
    end
  end

  def total_kills
    names = WeaponStat.column_names

    sum = 0
    names.each do |name|
      sum += user.weapon_stat[name] if name.include?('weapon_kills_') && user.weapon_stat[name]
    end
    p sum
  end
end
