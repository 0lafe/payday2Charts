class MiscStat < ApplicationRecord
  belongs_to :user

  def self.get_top_100(name)
    users = MiscStat.includes(:user)
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

  def total_heists
    names = MiscStat.column_names

    sum = 0
    names.each do |name|
      sum += user.misc_stat[name] if name.include?('contract_') && user.misc_stat[name] && name.include?('_win')
    end
    p sum
  end

  def perkdeck_list
    23.times.map do |i|
      {
        name: "specialization_used_#{i + 1}",
        value: self["specialization_used_#{i + 1}"]
      }
    end
  end
end
