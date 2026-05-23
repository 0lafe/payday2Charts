class Stat < ApplicationRecord
  include Localizable
  
  has_many :user_stats

  validates :name, uniqueness: true

  def self.from_internal_name(name, filter)
    name = if name.starts_with?("bm_w")
      name.gsub("bm_w", "weapon_#{filter}")
    elsif name.starts_with?("bm_melee")
      name.gsub("bm_melee", "melee_#{filter}")
    else
      name.gsub("bm_throwable", "grenade_#{filter}")
    end

    find_by(name:)
  end

  def weapon?
    stat_type == "weapon"
  end

  def melee?
    stat_type == "melee"
  end

  def throwable?
    stat_type == "throwable"
  end

  def grouping?
    weapon? || melee? || throwable?
  end

  def other_grouped_stats(prefixes)
    case stat_type
    when "weapon"
      prefixes.map do |prefix|
        base_name.gsub("bm_w", "weapon_#{prefix}")
      end
    when "melee"
      prefixes.map do |prefix|
        base_name.gsub("bm_melee", "melee_#{prefix}")
      end
    when "throwable"
      prefixes.map do |prefix|
        base_name.gsub("bm_throwable", "grenade_#{prefix}")
      end
    end
  end

  def translate_weapon_stat_to_url
    filter = name.split("_")[1]
    Rails.application.routes.url_helpers.leaderboard_path(base_name, filter:)
  end
end