class GuessWho < ApplicationRecord
  before_create :set_items

  validates :game_type, presence: true

  ALL_LISTS = JSON.parse(File.read(Rails.root.join("app/models/concerns/guess_who_lists.json")))
  HEIST_LIST = JSON.parse(File.read(Rails.root.join("app/models/concerns/heists.json")))

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
    black_list = ALL_LISTS["black_list"]

    stats = SteamApi.schema.filter do |stat|
      stat["name"].starts_with?(stat_type) && !black_list.include?(stat["name"])
    end

    stats.map do |stat|
      stat["name"]
    end
  end

  def set_items
    if game_type == "heist"
      self.items = HEIST_LIST.sample(24)
    elsif game_type == "content_creators"
      self.items = ALL_LISTS["content_creators_list_bak"].sample(24)
    elsif game_type == "characters"
      self.items = ALL_LISTS["characters_list"].sample(24)
    elsif game_type == "skins"
      self.items = ALL_LISTS["skins"].keys.sample(24)
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
    ALL_LISTS["skins"][skin_id]
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

  def self.update_avatars
    @creator_list = ALL_LISTS["content_creators_list"]

    @youtube = @creator_list.filter {|creator| creator["platform"] == "yt" }
    @twitch = @creator_list - @youtube


    ids = @youtube.map do |creator|
      creator["id"]
    end
    
    reply = YoutubeApi.get_avatars(ids)
    
    youtube_results = {}
    reply["items"].each do |user|
      id = user["id"]
      avatar_url = user["snippet"]["thumbnails"]["high"]["url"]
      youtube_results[id] = avatar_url
    end

    youtube_out = @youtube.map do |user|
      user["avatar_url"] = youtube_results[user["id"]]
      user
    end

    byebug
  end
end