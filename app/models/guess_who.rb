class GuessWho < ApplicationRecord
  before_create :set_items

  validates :game_type, presence: true

  def self.game_types
    [
      ["Heist", "heist"],
      ["Mask", "mask"],
      ["Weapon", "weapon"],
      ["Melee", "melee"],
      ["Content Creators", "content_creators"],
      ["Characters", "characters"],
      ["Skins", "skins"],
    ]
  end

  def get_stat_names(stat_type)
    black_list = JSON.parse(File.read("./app/models/guess_who_lists.json"))["black_list"]

    stats = SteamApi.schema.filter do |stat|
      stat["name"].starts_with?(stat_type) && !black_list.include?(stat["name"])
    end

    stats.map do |stat|
      stat["name"]
    end
  end

  def set_items
    lists = JSON.parse(File.read("./app/models/guess_who_lists.json"))
    if game_type == "heist"
      self.items = lists["heist_list"].sample(24)
    elsif game_type == "content_creators"
      self.items = lists["content_creators_list"].sample(24)
    elsif game_type == "characters"
      self.items = lists["characters_list"].sample(24)
    elsif game_type == "skins"
      self.items = lists["skins"].keys.sample(24)
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

  def self.skin_data(skin_id)
    @lists ||= JSON.parse(File.read("./app/models/guess_who_lists.json"))
    @lists["skins"][skin_id]
  end

  def self.skin_background(skin_id)
    rarity = skin_data(skin_id)["rarity"]
    case rarity
    when "common"
      "https://fbi.paydaythegame.com/assets/img/weapons/skins/rarity-1.png"
    when "uncommon"
      "https://fbi.paydaythegame.com/assets/img/weapons/skins/rarity-2.png"
    when "rare"
      "https://fbi.paydaythegame.com/assets/img/weapons/skins/rarity-3.png"
    when "epic"
      "https://fbi.paydaythegame.com/assets/img/weapons/skins/rarity-4.png"
    when "legendary"
      "https://fbi.paydaythegame.com/assets/img/weapons/skins/rarity-5.png"
    end
  end
end