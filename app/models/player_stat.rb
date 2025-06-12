class PlayerStat < ApplicationRecord
  belongs_to :user

  def self.get_top_100(name)
    users = PlayerStat.includes(:user)
      .where.not(user: { banned: true })
      .where.not({name => nil})
      .order("#{name} DESC")
      .limit(100)
      .select(
        :user_id,
        :updated_at,
        name
      )

    names = SteamApi.get_multiple_user_data(users.map {|player| player.user.steam_id })
    users.map.with_index do |a, index|
      {
        name: names[index][:name],
        avatar: names[index][:avatar],
        steam_id: a.user.steam_id,
        value: a[name],
        updated_at: a.updated_at
      }
    end
  end
end