class Localizer
  @base_url = "https://fbi.paydaythegame.com/img/"

  def self.generate_image_url(statistic, size = "thumbs")
    setup_files
    uuid = statistic
    uuid = @overkill_goofs[uuid.to_sym] if @overkill_goofs[uuid.to_sym]
    @stats.keys.each do |stat|
      uuid = uuid.gsub(stat.to_s, "")
    end
    url = if statistic.include?("melee_")
      "weapons/melee/#{size}/#{uuid}.png"
    elsif statistic.include?("weapon_")
      "weapons/ranged/#{size}/#{uuid}.png"
    elsif statistic.index("grenade_") == 0
      if statistic.include?("wpn_prj_") || statistic.include?("wpn_gre_")
        "weapons/thrown/#{size}/#{uuid.gsub("wpn_prj_", "").gsub("wpn_gre_", "")}.png"
      else
        "weapons/thrown/#{size}/#{uuid}.png"
      end
    elsif statistic.include?("mask_")
      "masks/thumb/#{uuid}_dif.png"
    elsif statistic.include?("gloves_")
      "gloves/#{size}/#{uuid}.png"
    elsif statistic.include?("suit_")
      "suits/#{size}/#{uuid}.png"
    elsif statistic.include?("difficulty_")
      "#{@difficulty_mappings[uuid]}.png"
    elsif statistic.include?("character_")
      "sketches/sketch-#{uuid}-large.jpg"
    elsif statistic.include?("armor_used_")
      "weapons/armors/#{size}/#{uuid}.png"
    elsif statistic.include?("gadget_used_")
      "weapons/equipment/#{size}/#{uuid}.png"
    elsif statistic.include?("specialization_used_")
      "weapons/perkdeck/thumbs/#{statistic.gsub("specialization_used_", "")}.png"
    elsif statistic.starts_with?("bm_w_")
      "weapons/ranged/#{size}/#{uuid}.png"
    elsif statistic.starts_with?("bm_melee_")
      "weapons/melee/#{size}/#{uuid}.png"
    elsif statistic.starts_with?("bm_throwable_")
      if statistic.include?("wpn_prj_") || statistic.include?("wpn_gre_")
        "weapons/thrown/#{size}/#{uuid.gsub("wpn_prj_", "").gsub("wpn_gre_", "")}.png"
      else
        "weapons/thrown/#{size}/#{uuid}.png"
      end
    elsif statistic.starts_with?("contract_")
      pure_name = uuid.gsub("_win", "").gsub("_dropin", "").gsub("_fail", "").gsub("_prof", "").gsub("skm_", "")
      heist_image_name = @heist_images[pure_name] || pure_name
      "heistinfo/#{heist_image_name}.jpg"
    end

    url && @base_url + url || ""
  end

  def self.remove_stat(name)
    @stats.keys.each do |stat|
      name = name.gsub(stat.to_s, "")
    end
    name
  end

  def self.localize_from_statistic(statistic)
    setup_files
    suffix = ""

    name = 
      if statistic.include?("melee_")
        "bm_melee_"
      elsif statistic.include?("weapon_charm_used_")
        ""
      elsif statistic.include?("weapon_color_used_")
        "bm_wskn_"
      elsif statistic.include?("weapon_")
        "bm_w_"
      elsif statistic.include?("mask_")
        "bm_msk_"
      elsif statistic.include?("gadget_")
        "bm_equipment_"
      elsif statistic.include?("grenade_")
        "bm_throwable_"
      elsif statistic.include?("gloves_used_")
        "bm_gloves_"
      elsif statistic.include?("suit_used")
        "bm_suit_"
      elsif statistic.include?("difficulty_")
        ""
      elsif statistic.include?("character_used")
        suffix = " (Character)"
        "bm_character_"
      elsif statistic.include?("armor_used")
        "bm_armor_"
      elsif statistic.include?("enemy_kills_")
        "enemy_"
      elsif statistic.include?("contract_")
        statistic = statistic.gsub("_prof", "")

        if statistic.include?("skm_")
          suffix += " Holdout"
          statistic = statistic.gsub("skm_", "")
        end

        if statistic.include?("_win_dropin")
          suffix += " Win (drop in)"
          statistic = statistic.gsub("_win_dropin", "")
        elsif statistic.include?("_win")
          suffix += " Win"
          statistic = statistic.gsub("_win", "")
        elsif statistic.include?("_fail")
          suffix += " Lose"
          statistic = statistic.gsub("_fail", "")
        end

        if statistic.end_with?("_night")
          suffix += " Night"
          statistic = statistic.gsub("_night", "")
        end

        "heist_"
      end

    name = name || ""

    uuid = statistic
    descriptor = ""
    @stats.keys.each do |stat|
      uuid = uuid.gsub(stat.to_s, "")
      descriptor = @stats[stat] if statistic.include?(stat.to_s)
    end
    begin
      name + uuid
    rescue
      false
    end
    descriptor + localize(name + uuid) + suffix
  end

  def self.weapon_from_stat(stat)
    stat
      .gsub("weapon_used", "bm_w")
      .gsub("weapon_kills", "bm_w")
      .gsub("weapon_shots", "bm_w")
      .gsub("weapon_hits", "bm_w")
  end

  def self.localize_weapon_from_stat(stat)
    localize(weapon_from_stat(stat))
  end

  def self.melee_from_stat(stat)
    stat
      .gsub("melee_used", "bm_melee")
      .gsub("melee_kills", "bm_melee")
  end

  def self.localize_melee_from_stat(stat)
    localize(melee_from_stat(stat))
  end

  def self.throwable_from_stat(stat)
    stat
      .gsub("grenade_used", "bm_throwable")
      .gsub("grenade_kills", "bm_throwable")
  end

  def self.localize_throwable_from_stat(stat)
    localize(throwable_from_stat(stat))
  end

  def self.localize(name)
    setup_files
    name = @overkill_goofs[name.to_sym] if @overkill_goofs[name.to_sym]
    @localization_file[name] || name
  end

  def self.setup_files
    @localization_file ||= JSON.parse(File.open("./app/services/localizations.json").read)
    @translation_file ||= JSON.parse(File.open("./app/services/localization_fbi_translations.json").read)
    @overkill_goofs = @translation_file["overkill_goofs"]
    @difficulty_mappings = @translation_file["difficulty_mappings"]
    @stats = @translation_file["stats"]
    @heist_images = @translation_file["heist_images"]
  end
end
