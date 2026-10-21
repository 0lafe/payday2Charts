class Leaderboard
  attr_accessor :updated_at, :top_100s

  def self.create
    top_100s = Stat.where(display: true).to_h do |stat|
      [
        stat.id,
        stat.user_stats
          .order(value: :desc)
          .limit(100)
          .map do |user_stat|
            [
              user_stat.user_id,
              user_stat.value
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

  def self.top_100s
    read["top_100s"] if up?
  end

  def self.user_positions(user)
    user_id = user.id

    data = top_100s.filter_map do |stat_id, users|
      [
        stat_id.to_i,
        users.index { |users| users.first == user_id }
      ] if users.index { |users| users.first == user_id }
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

