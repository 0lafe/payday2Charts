class GuessWho < ApplicationRecord
  before_create :set_items

  validates :game_type, presence: true

  def black_list
    [
      'weapon_kills_tec9',
      'grenade_kills_wpn_prj_ace',
      'suit_used_poolrepair_default',
      'weapon_shots_model70',
      'weapon_shots_x_p226',
      'weapon_shots_x_rage',
      'weapon_shots_x_uzi',
      'weapon_hits_x_akmsu',
      'weapon_hits_tecci',
      'weapon_hits_breech',
      'weapon_hits_tti',
      'weapon_hits_x_m45',
      'weapon_hits_coach',
      'player_time',
      'player_rank',
      'player_cash',
      'player_level',
      'player_coins',
      'skill_hoxton',
      'skill_chains',
      'skill_wolf',
      'skill_dallas',
      'skill_houston',
      'skill_mastermind',
      'skill_enforcer',
      'skill_ghost',
      'skill_technician',
      'skill_fugative',
      "mask_used_rvd_1",
      "mask_used_rvd_2",
      "mask_used_rvd_3",
      "mask_used_smo_hila_02",
      "mask_used_smo_common_02",
      "mask_used_smo_big_02",
      "mask_used_bny_03_bodhi",
      "mask_used_bny_03_clover",
      "mask_used_bny_02_bodhi",
      "mask_used_bny_02_bonnie",
      "mask_used_bny_02_clover",
      "mask_used_bny_02_bonnie",
      "mask_used_bny_01_bodhi",
      "mask_used_bny_01_clover_b",
      "mask_used_bny_01_clover",
      "mask_used_bny_01_bonnie",
      "mask_used_grv_01_bonnie",
      "mask_used_grv_01_bodhi",
      "mask_used_threap_hair",
      "mask_used_threap_default",
      "mask_used_funguy_hair",
      "mask_used_funguy_default"
    ]
  end

  def self.heist_list
    [
      "aftershockpng.png",
      "alaskan-dealpng.png",
      "alessopng.png",
      "art-gallerypng.png",
      "bank-heistpng.png",
      "beneath-the-mountainpng.png",
      "big-bankpng.png",
      "big-oilpng.png",
      "biker-heistpng.png",
      "birth-of-skypng.png",
      "black-catpng.png",
      "boiling-pointpng.png",
      "border-crossingpng.png",
      "border-crystalspng.png",
      "breakfastpng.png",
      "breakinpng.png",
      "brooklyn-10png.png",
      "brooklyn-bankpng.png",
      "bulucs-mansionpng.png",
      "car-shoppng.png",
      "cook-offpng.png",
      "counterfeitpng.png",
      "crude-awakening.png",
      "cursedpng.png",
      "diamond-heistpng.png",
      "diamond-storepng.png",
      "diamondpng.png",
      "dockyardpng.png",
      "dragon-heistpng.png",
      "election-daypng.png",
      "firestarterpng.png",
      "first-world-bankpng.png",
      "forestpng.png",
      "four-storespng.png",
      "framing-framepng.png",
      "go-bankpng.png",
      "goatpng.png",
      "golden-grin-casinopng.png",
      "green-bridgepng.png",
      "heatpng.png",
      "hellpng.png",
      "henrys-rockpng.png",
      "hostile-takeover.png",
      "hotlinepng.png",
      "hoxton-breakoutpng.png",
      "hoxton-revengepng.png",
      "jewelrypng.png",
      "lab-ratspng.png",
      "lost-in-transit.png",
      "mallcrasherpng.png",
      "meltdownpng.png",
      "midland-ranch.png",
      "mountain-master.png",
      "murkypng.png",
      "nightclubpng.png",
      "no-mercypng.png",
      "panic-roompng.png",
      "prisonpng.png",
      "ratspng.png",
      "reservoirpng.png",
      "safe-house-nightmarepng.png",
      "safe-house-raidpng.png",
      "san-martinpng.png",
      "santapng.png",
      "scarfacepng.png",
      "shacklepng.png",
      "shadow-raidpng.png",
      "slaughterpng.png",
      "stealing-xmaspng.png",
      "trainpng.png",
      "transportpng.png",
      "ukrainian-jobpng.png",
      "ukrainian-prisonerpng.png",
      "undercoverpng.png",
      "watchdogspng.png",
      "white-housepng.png",
      "white-xmaspng.png",
      "yachtpng.png"
    ]
  end

  def self.content_creators_list
    [
      "0lafe.PNG",
      "APX.PNG",
      "AZ.PNG",
      "Ace.PNG",
      "Amke.PNG",
      "Arthrad.PNG",
      "BOI.PNG",
      "Bay1k.PNG",
      "Carlos.PNG",
      "Carrot.PNG",
      "Cdawgg.PNG",
      "Commander.PNG",
      "CrabicGangster.png",
      "DINAX.PNG",
      "Darrel.PNG",
      "Dasher.PNG",
      "General.PNG",
      "Gorko7.PNG",
      "Hitmanguy.PNG",
      "Hoxtilicious.PNG",
      "Inigo.PNG",
      "Jaide.PNG",
      "Jesus.PNG",
      "Jocab.PNG",
      "Just a Cat.PNG",
      "KingZ.PNG",
      "Kknowley.PNG",
      "Lucky.PNG",
      "Marcbm.PNG",
      "Marioinatophat.PNG",
      "Martino.PNG",
      "Mortifier.PNG",
      "Niphen.PNG",
      "Payday.PNG",
      "RustyChains.PNG",
      "Semper.PNG",
      "Simon.PNG",
      "Spider.PNG",
      "Sprin.PNG",
      "Stol3n.PNG",
      "Timmy.PNG",
      "ToastedBread.PNG",
      "Tony.PNG",
      "Uncle.PNG",
      "Vyse.PNG",
      "Zdann.PNG",
      "akg.jpg",
      "alagusta.jpg",
      "altonator.jpg",
      "appii.PNG",
      "arco.png",
      "armorerfan.PNG",
      "b33croft.PNG",
      "bleetstreets.PNG",
      "bob feet.png",
      "capcake.jpg",
      "captainalpha.jpg",
      "cassius.jpg",
      "damon.PNG",
      "dazelux.jpg",
      "dwan.png",
      "e3k.PNG",
      "given.png",
      "heart.png",
      "hox.png",
      "itspansy.PNG",
      "jamesblack.jpg",
      "kev.PNG",
      "lilguyG.PNG",
      "mr wombat.png",
      "nash.jpg",
      "nico.jpg",
      "nikita.PNG",
      "nuka.png",
      "overcastspy.jpg",
      "pluto.png",
      "random kenny.png",
      "randomguy.PNG",
      "redarcherlive.PNG",
      "richard dangles.jpg",
      "rob thanatos.PNG",
      "russian badger.jpg",
      "salem.jpg",
      "sam.jpg",
      "sheri shaw.PNG",
      "staufackar.PNG",
      "tuanbomb.PNG",
      "unknownknight.PNG"
    ]
  end

  def get_schema
    response = HTTParty.get("https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=#{ENV['STEAM_KEY']}&appid=218620")
    if response.ok?
      data = JSON.parse(response.body)
      return data
    else
      return {error: response.headers}
    end
  end

  def get_stat_names(stat_type)
    stats = get_schema['game']['availableGameStats']['stats']
    stats = stats.filter {|stat| stat['name'].index(stat_type) == 0 }.map {|stat| stat['name'] }
    stats = stats.filter {|stat| !black_list.include?(stat) }
  end

  def self.game_types
    [
      ["Heist", "heist"],
      ["Mask", "mask"],
      ["Weapon", "weapon"],
      ["Melee", "melee"],
      ["Content Creators", "content_creators"]
    ]
  end

  def set_items
    if game_type == "heist"
      self.items = GuessWho.heist_list.sample(24)
    elsif game_type == "content_creators"
      self.items = GuessWho.content_creators_list.sample(24)
    else
      item_stats = []
      if game_type == "mask"
        item_stats = get_stat_names("mask_used").sample(24)
      elsif game_type == "weapon"
        item_stats = get_stat_names("weapon_kills").sample(24)
      elsif game_type == "melee"
        item_stats = get_stat_names("melee_kills").sample(24)
      end
      self.items = item_stats.map {|stat| Localizer.generate_image_url(stat) }
    end
  end
end