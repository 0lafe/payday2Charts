class Leaderboard
  attr_accessor :updated_at, :top_100s

  def self.create
    top_100s = Stat.where(display: true).to_h do |stat|
      [
        stat.id,
        stat.user_stats
          .order(value: :desc)
          .limit(100)
          .each_with_index
          .to_h do |user_stat, index|
            [
              user_stat.user_id,
              index
            ]
          end
      ]
    end

    updated_at = Time.now.to_formatted_s(:short)

    return {
      top_100s:,
      updated_at:
    }
  end

  def self.up?
    REDIS_CLIENT.exists?("lb")
  end

  def self.read
    JSON.parse(REDIS_CLIENT.get('lb'))
  end

  def self.user_positions(user)
    # user_id = user.id
    # out = []
    # ['weapon_stat', 'player_stat', 'misc_stat'].each do |type|
    #   filtered = Leaderboard.read['top_100s'][type].filter do |stat|
    #     stat['values'].include?(user_id)
    #   end
    #   filtered.each do |stat|
    #     out << {
    #       name: stat['name'],
    #       value: stat['values'].index(user_id)
    #     }
    #   end
    # end
    # out

    user_id = user.id.to_s
    data = read["top_100s"].filter_map do |stat_id, users|
      [
        stat_id.to_i,
        users[user_id]
      ] if users[user_id].present?
    end

    stats = Stat.where(id: data.map(&:first)).group_by(&:id)

    data.map do |stat|
      {
        stat: stats[stat[0]].first,
        value: stat[1]
      }
    end.sort_by do |val|
      val[:value]
    end
  end
end

