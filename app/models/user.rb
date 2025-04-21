class User < ApplicationRecord
  has_one :weapon_stat, dependent: :destroy
  has_one :player_stat, dependent: :destroy
  has_one :misc_stat, dependent: :destroy

  def steam_data
    @steam_user_data = SteamApi.get_user_data(steam_id) unless @steam_user_data

    @steam_user_data
  end

  def name
    steam_data[:name]
  end

  def avatar
    steam_data[:avatar]
  end

  def fetch_new_stats
    weapon_stats, player_stats, misc_stats = PlayerStatGrabber.update_stats_hash(steam_id)

    if weapon_stat.present?
      weapon_stat.update(weapon_stats)
    else
      WeaponStat.create(weapon_stats.merge({user_id: id}))
    end

    if player_stat.present?
      player_stat.update(player_stats)
    else
      PlayerStat.create(player_stats.merge({user_id: id}))
    end

    if misc_stat.present?
      misc_stat.update(misc_stats)
    else
      MiscStat.create(misc_stats.merge({user_id: id}))
    end
  end

  def self.me
    User.find_by(steam_id: 76561198043378601)
  end
end
