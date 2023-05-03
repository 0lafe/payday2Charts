class StatSearchComponent < ViewComponent::Base
  def initialize(class_name = '')
    non_stats = [
      'id',
      'user_id',
      'steam_id',
      'created_at',
      'updated_at'
    ]
    ws = WeaponStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    ps = PlayerStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    ms = MiscStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    @options = ws.concat(ps.concat(ms)).filter do |stat|
      !non_stats.include?(stat[1])
    end
    @class_name = class_name
  end
end