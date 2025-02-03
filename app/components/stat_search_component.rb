class StatSearchComponent < ViewComponent::Base
  def initialize(class_name = "")
    # columns on tables that don't corolate to stats
    non_stats = [
      "id",
      "user_id",
      "steam_id",
      "created_at",
      "updated_at"
    ]

    # stats that don't need LBs such as achievement completion or menu settings
    stat_start_filters = [
      "player_",
      "skill_",
      "halloween_",
      "armored_",
      "gage_",
      "gage2_",
      "gage3_",
      "gage4_",
      "gage5_",
      "gmod_",
      "option_",
      "specialization_",
      "option_",
      "equipped_",
      "crimefest_",
      "job_",
      "level_",
      "join_stinger_used_",
      "main_menu_",
      "heist_",
      "pda_",
      "pxp1_",
      "pxp2_",
      "ranc_",
      "setting_",
      "cac_",
      "eng_",
      "rvd_",
      "info_",
      "sb17_",
      "pim_",
    ]

    ws = WeaponStat.column_names.map do |unlocalized_name|
      if weapon_stat?(unlocalized_name)
        [
          Localizer.localize_weapon_from_stat(unlocalized_name),
          Localizer.weapon_from_stat(unlocalized_name),
          {
            "data-grouping": "weapon"
          }
        ]
      elsif melee_stat?(unlocalized_name)
        [
          Localizer.localize_melee_from_stat(unlocalized_name),
          Localizer.melee_from_stat(unlocalized_name),
          {
            "data-grouping": "melee"
          }
        ]
      elsif throwable_stat?(unlocalized_name)
        [
          Localizer.localize_throwable_from_stat(unlocalized_name),
          Localizer.throwable_from_stat(unlocalized_name),
          {
            "data-grouping": "throwable"
          }
        ]
      else
        [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
      end
    end
    ps = PlayerStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end
    ms = MiscStat.column_names.map do |unlocalized_name|
      [Localizer.localize_from_statistic(unlocalized_name), unlocalized_name]
    end

    @options = ws.uniq.concat(ps.concat(ms)).filter do |stat|
      !non_stats.include?(stat[1])
    end
    stat_start_filters.each do |black_list|
      @options = @options.filter do |stat|
        !stat[0].starts_with?(black_list)
      end
    end

    @class_name = class_name
  end

  def weapon_stat?(stat)
    stat.starts_with?("weapon_used_") || stat.starts_with?("weapon_kills_") || stat.starts_with?("weapon_shots_") || stat.starts_with?("weapon_hits_")
  end

  def melee_stat?(stat)
    stat.starts_with?("melee_kills_") || stat.starts_with?("melee_used_")
  end

  def throwable_stat?(stat)
    stat.starts_with?("grenade_kills_") || stat.starts_with?("grenade_used_")
  end
end
