class Localizer

  @stats = {
    'melee_kills_': 'Kills with ',
    'melee_used_': 'Usage for ',
    'weapon_kills_': 'Kills with ',
    'weapon_used_': 'Usage for ',
    'weapon_shots_': 'Shots with ',
    'weapon_hits_': 'Shots hit ',
    'mask_used_': 'Usage for ',
    'gadget_used_': 'Usage for ',
    'grenade_kills_': 'Kills with ',
    'grenade_used_': 'Usage for ',
    'gloves_used_': 'Usage for ',
    'suit_used_': 'Usage for ',
    'character_used_': 'Usage for ',
    'enemy_kills_': 'Kills on ',
    'armor_used_': 'Usage for ',
    'contract_': ''
  }

  @overkill_goofs = {
    'bm_equipment_first_aid': 'bm_equipment_first_aid_kit',
    'bm_equipment_body_bag': 'bm_equipment_bodybags_bag',
    'bm_equipment_armor_bag': 'bm_equipment_armor_kit',
    'gadget_used_first_aid': 'gadget_used_first_aid_kit',
    'gadget_used_body_bag': 'gadget_used_bodybags_bag',
    'gadget_used_armor_bag': 'gadget_used_armor_kit',
    'bm_grenade_wpn_prj_ace': 'bm_grenade_ace',
    'grenade_used_wpn_prj_ace': 'grenade_used_ace',
    'grenade_used_wpn_prj_four': 'grenade_used_four',
    'grenade_used_wpn_prj_target': 'grenade_used_target',
    'grenade_used_wpn_prj_jav': 'grenade_used_jav',
    'grenade_used_wpn_prj_hur': 'grenade_used_hur',
    'grenade_used_wpn_gre_electric': 'grenade_used_electric'
  }

  @difficulty_mappings = {
    'difficulty_sm_wish': 'heist-dif-6',
    'difficulty_overkill_290': 'heist-dif-5',
    'difficulty_easy_wish': 'heist-dif-4',
    'difficulty_overkill_145': 'heist-dif-3',
    'difficulty_overkill': 'heist-dif-2',
    'difficulty_hard': 'heist-dif-1',
    'difficulty_normal': 'heist-dif-0',
    'difficulty_easy': 'heist-dif-0'
  }

  @unit_mappings = {

  }

  def self.generate_image_url(statistic)
    uuid = statistic
    uuid = @overkill_goofs[uuid.to_sym] if @overkill_goofs[uuid.to_sym]
    @stats.keys.each do |stat|
      uuid = uuid.gsub(stat.to_s, '')
    end
    url = if statistic.include?('melee_')
      "https://fbi.paydaythegame.com/img/weapons/melee/thumbs/#{uuid}.png"
    elsif statistic.include?('weapon_')
      "https://fbi.paydaythegame.com/img/weapons/ranged/thumbs/#{uuid}.png"
    elsif statistic.index('grenade_') == 0
      "https://fbi.paydaythegame.com/img/weapons/thrown/thumbs/#{uuid}.png"
    elsif statistic.include?('mask_')
      "https://fbi.paydaythegame.com/img/masks/thumb/#{uuid}_dif.png"
    elsif statistic.include?('gloves_')
      "https://fbi.paydaythegame.com/img/gloves/thumbs/#{uuid}.png"
    elsif statistic.include?('suit_')
      "https://fbi.paydaythegame.com/img/suits/thumbs/#{uuid}.png"
    elsif statistic.include?('difficulty_')
      "https://fbi.paydaythegame.com/img/#{@difficulty_mappings[uuid.to_sym]}.png"
    elsif statistic.include?('character_')
      "https://fbi.paydaythegame.com/img/sketches/sketch-#{uuid}-large.jpg"
    elsif statistic.include?('armor_used_')
      "https://fbi.paydaythegame.com/img/weapons/armors/thumbs/#{uuid}.png"
    elsif statistic.include?('gadget_used_')
      "https://fbi.paydaythegame.com/img/weapons/equipment/thumbs/#{uuid}.png"
    end

    url = '' unless url

    url
  end

  def self.remove_stat(name)
    @stats.keys.each do |stat|
      name = name.gsub(stat.to_s, '')
    end
    name
  end

  def self.localize_from_statistic(statistic)
    suffix = ''

    name = if statistic.include?('melee_')
      'bm_melee_'
    elsif statistic.include?('weapon_')
      'bm_w_'
    elsif statistic.include?('mask_')
      if statistic.include?('mask_used_cop_kawaii') || statistic.include?('mask_used_cop_skull') || statistic.include?('mask_used_cop_plague_doctor')
        'bm_'
      else
        'bm_msk_'
      end
    elsif statistic.include?('gadget_')
      'bm_equipment_'
    elsif statistic.include?('grenade_')
      if statistic.include?('_wpn_') || statistic.include?('_concussion') || statistic.include?('_dynamite')
        'bm_'
      else
        'bm_grenade_'
      end
    elsif statistic.include?('gloves_used_')
      'bm_gloves_'
    elsif statistic.include?('suit_used')
      'bm_suit_'
    elsif statistic.include?('difficulty_')
      'menu_'
    elsif statistic.include?('character_used')
      suffix = ' (Character)'
      'menu_'
    elsif statistic.include?('armor_used')
      'bm_armor_'
    elsif statistic.include?('contract_')
      if statistic.include?('_win_dropin')
        suffix = ' Win (drop in)'
        statistic = statistic.gsub('_win_dropin', '')
      elsif statistic.include?('_win')
        suffix = ' Win'
        statistic = statistic.gsub('_win', '')
      elsif statistic.include?('_fail')
        suffix = ' Lose'
        statistic = statistic.gsub('_fail', '')
      end
      'heist_'
    end

    name = '' unless name

    uuid = statistic
    descriptor = ''
    @stats.keys.each do |stat|
      uuid = uuid.gsub(stat.to_s, '')
      descriptor = @stats[stat] if statistic.include?(stat.to_s)
    end
    begin
      name + uuid
    rescue
      byebug
    end
    descriptor + localize(name + uuid) + suffix
  end

  def self.localize(name)
    @localization_file ||= JSON.parse(File.open('./app/services/localizations.json').read)
    name = @overkill_goofs[name.to_sym] if @overkill_goofs[name.to_sym]
    @localization_file[name] || name
  end

  def self.obtain_json()
    hash = {}
    Dir['./app/services/xml/*'].each do |path|
      file = File.read(path)
      stripped = file.gsub("\r", '').gsub("\n", '').gsub('<string ', "").gsub('</string>', '&&&').split('&&&')
      stripped.map do |item|
        unlocalized = item[4..item.index("\"", 4) - 1]
        localized = item[item.index('>') + 1..]
        hash[unlocalized] = localized
      end
    end
    File.write('./app/services/localizations.json', hash.to_json)
  end
end