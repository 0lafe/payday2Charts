module LeaderboardsHelper
  def stat_value(stat, key, filter, lookup)
    if key == filter
      stat.value
    else
      lookup.dig(stat.user_id, key) || nil
    end
  end
end