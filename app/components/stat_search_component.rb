class StatSearchComponent < ViewComponent::Base
  def initialize
    @options = Rails.cache.fetch("stat_search_options", expires_in: 1.hour) do
      weapons = Stat.where(display: true, stat_type: "weapon").map do |stat|
        [
          Localizer.localize_weapon_from_stat(stat.name),
          Localizer.weapon_from_stat(stat.name),
          'kills'
        ]
      end.uniq
      
      melees = Stat.where(display: true, stat_type: "melee").map do |stat|
        [
          Localizer.localize_melee_from_stat(stat.name),
          Localizer.melee_from_stat(stat.name),
          'kills'
        ]
      end.uniq

      throwables = Stat.where(display: true, stat_type: "throwable").map do |stat|
        [
          Localizer.localize_throwable_from_stat(stat.name),
          Localizer.throwable_from_stat(stat.name),
          'kills'
        ]
      end.uniq

      other = Stat.where(display: true).where.not(stat_type: ['weapon', 'melee', 'throwable']).map do |stat|
        [
          stat.localize,
          stat.name
        ]
      end

      weapons.concat(melees.concat(throwables.concat(other)))
    end

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

    @options = groups.concat(other)
  end
end
