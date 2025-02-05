class MiscStat < ApplicationRecord
  belongs_to :user

  def self.get_top_100(name)
    users = MiscStat.where.not({name => nil}).order("#{name} DESC").includes(:user).limit(100)
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

  def total_heists
    names = MiscStat.column_names

    sum = 0
    names.each do |name|
      sum += user.misc_stat[name] if name.include?('contract_') && user.misc_stat[name] && name.include?('_win')
    end
    p sum
  end

  def perkdeck_list
    list = 23.times.map do |i|
      {
        name: "specialization_used_#{i + 1}",
        value: self["specialization_used_#{i + 1}"]
      }
    end
  end
end
