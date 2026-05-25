class User < ApplicationRecord
  attr_accessor :steam_name
  attr_accessor :steam_avatar

  has_many :steam_items
  has_many :user_stats, dependent: :delete_all

  scope :unbanned, -> { where(banned: false) }
  scope :banned, -> { where(banned: true) }

  validates :steam_id, presence: true
  validates :steam_id, uniqueness: true
  validates :steam_id, format: {
    with: /\A76561198\d{9}\z/,
    message: "must be a valid steamID64"
  }

  validates :banned, inclusion: { in: [true, false] }

  before_create :strip_steam_id

  def strip_steam_id
    self.steam_id = self.steam_id.gsub(/\D/, '')
  end

  def steam_data
    @steam_user_data = SteamApi.get_user_data(steam_id) unless @steam_user_data

    @steam_user_data
  end

  def name
    steam_data[:name]
  end

  def avatar
    steam_data[:avatar]
  end

  def update_user_stats
    return if banned?

    response = SteamApi.get("ISteamUserStats/GetUserStatsForGame/v2/",
      { appid: "218620", steamid: steam_id }
    )

    stat_data = response.dig("playerstats", "stats")

    stat_names = stat_data.map do |stat|
      stat["name"]
    end

    stat_id_lookup = Stat.where(name: stat_names).pluck(:name, :id).to_h

    inserts = stat_data.map do |stat|
      {
        user_id: id,
        stat_id: stat_id_lookup[stat["name"]],
        value: stat["value"],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    UserStat.where(user_id: id).delete_all

    UserStat.insert_all(inserts)
  end

  def me?
    ["76561199634345752", "76561198043378601"].include?(steam_id)
  end

  def self.me
    find_by(steam_id: 76561198043378601)
  end

  def self.top_item_count
    joins(:steam_items)
      .select("users.*, SUM(steam_items.amount) AS total_items")
      .group("users.id")
      .order("total_items DESC")
      .limit(25)
  end
  
  def self.top_individual_item_count
    joins(:steam_items)
      .select("users.*, MAX(steam_items.amount) AS max_quantity")
      .group("users.id")
      .order("max_quantity DESC")
      .limit(25)
  end

  def self.top_worth_median
    joins(steam_items: :steam_item_data)
      .select("users.*, SUM(steam_items.amount * steam_item_data.median_price) AS total_value")
      .group("users.id")
      .order("total_value DESC")
      .limit(25)
  end

  def self.has_item(name)
    joins(steam_items: :steam_item_data)
      .where("steam_item_data.name ilike ?", "%#{name}%")
      .select("users.*, SUM(steam_items.amount) AS total_amount")
      .group("users.id")
      .order("total_amount DESC")
  end
end
