class SteamItemData < ApplicationRecord
  validates :icon_url, :name, :name_color, :tradable, :item_type, presence: true
  validates :marketable, inclusion: { in: [true, false] }

  has_many :steam_items, foreign_key: :class_id, primary_key: :id

  def self.missing_data
    existing_ids = SteamItemData.all.map(&:id)
    ids_to_add = SteamItem.select(:class_id).distinct.map {|item| item.class_id.to_i }.filter {|id| !existing_ids.include?(id) }
    ids_to_add.each_slice(20) do |slice|
      params = {
        "class_count" => slice.length,
        "appid" => "218620"
      }
      slice.each_with_index do |id, index|
        params["classid#{index}"] = id
      end

      response = SteamApi.get(
        "ISteamEconomy/GetAssetClassInfo/v1/",
        params
      )

      if response.ok?
        data = JSON.parse(response.body)["result"]
        
        slice.each do |id|
          tag_data = {}
          item_data = data[id.to_s]
          item_data["tags"].values.each do |tag|
            tag_data[tag["category"]] = tag["internal_name"]
          end

          SteamItemData.create(
            id: id.to_i,
            icon_url: item_data["icon_url"],
            name: item_data["name"],
            name_color: item_data["name_color"],
            tradable: item_data["tradable"] == "1",
            marketable: item_data["marketable"] == "1",
            commodity: item_data["commodity"] == "1",
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
