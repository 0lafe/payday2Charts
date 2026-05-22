module Localizable
  extend ActiveSupport::Concern

  def localize
    Localizer.localize_from_statistic(name)
  end

  def image(size: nil)
    Localizer.generate_image_url(name, size)
  end

  def base_name
    case stat_type
    when "weapon"
      Localizer.weapon_from_stat(name)
    when "melee"
      Localizer.melee_from_stat(name)
    when "throwable"
      Localizer.throwable_from_stat(name)
    end
  end

  def localized_base_name
    case stat_type
    when "weapon"
      Localizer.localize_weapon_from_stat(name)
    when "melee"
      Localizer.localize_melee_from_stat(name)
    when "throwable"
      Localizer.localize_throwable_from_stat(name)
    end
  end
end