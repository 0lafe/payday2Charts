class StatSearchComponent < ViewComponent::Base
  def initialize
    @options = Rails.cache.fetch("stat_search_options", expires_in: 1.day) do
      groups = Stat.where(display: true, stat_type: ["weapon", "melee", "throwable"]).map do |stat|
        [
          stat.localized_base_name,
          stat.base_name,
          'kills'
        ]
      end.uniq

      other = Stat.where(display: true).where.not(stat_type: ['weapon', 'melee', 'throwable']).map do |stat|
        [
          stat.localize,
          stat.name
        ]
      end

      groups.concat(other)
    end
  end
end
