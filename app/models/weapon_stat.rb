class WeaponStat < ApplicationRecord
  belongs_to :user

  def self.get_top_100(record_name, filter = nil)
    if filter
      top_100_filter(record_name, filter)
    else
      users = WeaponStat.where.not({record_name => nil}).order("#{record_name} DESC").includes(:user).limit(100)
      names = User.steam_data(users.map {|player| player.user.steam_id })
      users.map.with_index do |a, index|
        {
          name: names[index][:name],
          avatar: names[index][:avatar],
          steam_id: a.user.steam_id,
          value: a[record_name],
          updated_at: a.updated_at
        }
      end
    end
  end

  def self.lowest_kills
    kill_stats = column_names.filter do |name|
      name.index('weapon_kills_') == 0
    end

    kill_stats.map do |stat|
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

  def self.has_filtering?(stat)
    weapon_stat?(stat) || melee_stat?(stat) || throwable_stat?(stat)
  end

  def self.weapon_stat?(stat)
    stat.starts_with?("weapon_used_") || stat.starts_with?("weapon_kills_") || stat.starts_with?("weapon_shots_") || stat.starts_with?("weapon_hits_")
  end

  def self.melee_stat?(stat)
    stat.starts_with?("melee_kills_") || stat.starts_with?("melee_used_")
  end

  def self.throwable_stat?(stat)
    stat.starts_with?("grenade_kills_") || stat.starts_with?("grenade_used_")
  end

  def self.translate_weapon_stat_to_url(stat)
    name_id = ""
    grouping = ""
    if self.weapon_stat?(stat)
      grouping = "weapon"
      name_id = Localizer.weapon_from_stat(stat)
    elsif self.melee_stat?(stat)
      grouping = "melee"
      name_id = Localizer.melee_from_stat(stat)
    elsif self.throwable_stat?(stat)
      grouping = "throwable"
      name_id = Localizer.throwable_from_stat(stat)
    end
    filter = stat.split("_")[1]
    Rails.application.routes.url_helpers.leaderboard_path(name_id, grouping:, filter:)
  end

  private

  def self.top_100_filter(name, filter)
    record = ""
    type = ""
    if name.starts_with?("bm_w")
      type = "weapon_"
      record = name.gsub("bm_w", "weapon_#{filter}")
    elsif name.starts_with?("bm_melee")
      type = "melee_"
      record = name.gsub("bm_melee", "melee_#{filter}")
    else
      type = "grenade_"
      record = name.gsub("bm_throwable", "grenade_#{filter}")
    end

    users = WeaponStat.where.not({record => nil}).order("#{record} DESC").includes(:user).limit(100)
    names = User.steam_data(users.map {|player| player.user.steam_id })

    users.map.with_index do |a, index|
      {
        name: names[index][:name],
        avatar: names[index][:avatar],
        steam_id: a.user.steam_id,
        kills: a[record.gsub("#{type}#{filter}", "#{type}kills")],
        uses: a[record.gsub("#{type}#{filter}", "#{type}used")],
        shots: a[record.gsub("#{type}#{filter}", "#{type}shots")],
        hits: a[record.gsub("#{type}#{filter}", "#{type}hits")],
        updated_at: a.updated_at
      }
    end
  end
end
