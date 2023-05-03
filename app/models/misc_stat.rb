class MiscStat < ApplicationRecord
  belongs_to :user

  def self.get_top_10(name)
    users = MiscStat.where.not({name => nil}).order("#{name} DESC").includes(:user).limit(100)
    names = User.names(users.map {|player| player.user.steam_id })
    users.map.with_index do |a, index|
      {
        name: names[index],
        steam_id: a.user.steam_id,
        value: a[name]
      }
    end
  end

  
  def self.user_in_top_10?(user)
    this_id = user.id
    column_names.filter do |column|
      MiscStat.where.not({column => nil}).order("#{column} DESC").limit(100).pluck(:user_id).index(this_id)
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
end
