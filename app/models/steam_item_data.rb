class SteamItemData < ApplicationRecord
  validates :icon_url, :name, :name_color, :tradable, :marketable, :item_type, presence: true

  has_many :steam_items, foreign_key: :class_id, primary_key: :id

  def self.missing_data
    SteamItem.select(:class_id).distinct.each_slice(20) do |slice|
      missing_ids = slice.map(&:class_id).filter do |id|
        !SteamItemData.exists?(id:)
      end

      next unless missing_ids.length.positive?

      params = {
        "class_count" => missing_ids.length,
        "appid" => "218620"
      }
      missing_ids.each_with_index do |id, index|
        params["classid#{index}"] = id
      end

      response = SteamApi.get(
        "ISteamEconomy/GetAssetClassInfo/v1/",
        params
      )

      if response.ok?
        data = JSON.parse(response.body)["result"]
        
        missing_ids.each do |id|
          tag_data = {}
          data[id]["tags"].values.each do |tag|
            tag_data[tag["category"]] = tag["internal_name"]
          end

          SteamItemData.create(
            id: id.to_i,
            icon_url: data[id]["icon_url"],
            name: data[id]["name"],
            name_color: data[id]["name_color"],
            tradable: data[id]["tradable"] == "1",
            marketable: data[id]["marketable"] == "1",
            commodity: data[id]["commodity"] == "1",
            item_type: tag_data["type"],
            quality: tag_data["quality"],
            rarity: tag_data["rarity"],
            bonus: tag_data["bonus"],
            collection: tag_data["collection"],
          )
        end
      else
        byebug
      end
    end
  end
end
