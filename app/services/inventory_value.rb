class InventoryValue
  def self.user_list_json
    REDIS_CLIENT.set("inventory_value_lb_median", median_list_setup.to_json)
    REDIS_CLIENT.set("top_item_lb", item_count_list_setup.to_json)
    REDIS_CLIENT.set("top_individual_item_lb", individual_item_count_list_setup.to_json)
    REDIS_CLIENT.set("average_price_lb", pricing_list_setup(:average_price).to_json)
    REDIS_CLIENT.set("median_price_lb", pricing_list_setup(:median_price).to_json)
    REDIS_CLIENT.set("highest_price_lb", pricing_list_setup(:highest_price).to_json)
    REDIS_CLIENT.set("highest_quantity_lb", pricing_list_setup(:highest_price).to_json)
    REDIS_CLIENT.set("item_existance_lb", item_existance_count_list_setup.to_json)
  end

  def self.median_list_setup
    users = User.top_worth_median.map do |user|
      {
        id: user.id,
        steam_id: user.steam_id,
        total_value: user.total_value.to_f * 0.013
      }
    end

    steam_names = SteamApi.get_multiple_user_data(users.map {|u| u[:steam_id] })
    steam_names = steam_names.each_with_object({}) do |data, hash|
      hash[data[:steam_id]] = {
        name: data[:name],
        avatar: data[:avatar]
      }
    end

    users.map do |user|
      user[:name] = steam_names[user[:steam_id]][:name]
      user[:avatar] = steam_names[user[:steam_id]][:avatar]
      user
    end
  end

  def self.item_count_list_setup
    users = User.top_item_count.map do |user|
      {
        id: user.id,
        steam_id: user.steam_id,
        total_items: user.total_items
      }
    end

    steam_names = SteamApi.get_multiple_user_data(users.map {|u| u[:steam_id] })
    steam_names = steam_names.each_with_object({}) do |data, hash|
      hash[data[:steam_id]] = {
        name: data[:name],
        avatar: data[:avatar]
      }
    end

    users.map do |user|
      user[:name] = steam_names[user[:steam_id]][:name]
      user[:avatar] = steam_names[user[:steam_id]][:avatar]
      user
    end
  end

  def self.individual_item_count_list_setup
    users = User.where(id: User.top_individual_item_count.map(&:id)).includes(:steam_items).map do |user|
      highest_stack = user.steam_items.sort_by { |item| item.amount }.reverse.first
      {
        id: user.id,
        steam_id: user.steam_id,
        total_items: highest_stack.amount,
        item_name: highest_stack.steam_item_data.name,
        item_image_url: highest_stack.steam_item_data.image_url
      }
    end

    users = users.sort_by { |user| user[:total_items] }.reverse

    steam_names = SteamApi.get_multiple_user_data(users.map {|u| u[:steam_id] })
    steam_names = steam_names.each_with_object({}) do |data, hash|
      hash[data[:steam_id]] = {
        name: data[:name],
        avatar: data[:avatar]
      }
    end

    users.map do |user|
      user[:name] = steam_names[user[:steam_id]][:name]
      user[:avatar] = steam_names[user[:steam_id]][:avatar]
      user
    end
  end

  def self.pricing_list_setup(type)
    SteamItemData.order(type => :desc).includes(:steam_items).limit(25).map do |item|
      {
        name: item.name,
        image_url: item.image_url,
        price: item[type].to_f * 0.013,
        link: item.market_page_url,
        amount: item.steam_items.sum(:amount)
      }
    end
  end

  def self.item_existance_count_list_setup
    items = SteamItemData
      .joins(:steam_items)
      .select("steam_item_data.*, SUM(steam_items.amount) AS max_quantity")
      .group("steam_item_data.id")
      .order("max_quantity DESC")
      .limit(25)

    items.map do |item|
      {
        name: item.name,
        image_url: item.image_url,
        amount: item.max_quantity,
        price: item.median_price.to_f * 0.013,
        link: item.market_page_url
      }
    end
  end
end