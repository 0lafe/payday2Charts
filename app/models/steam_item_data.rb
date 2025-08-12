class SteamItemData < ApplicationRecord
  validates :icon_url, :name, :name_color, :tradable, :item_type, presence: true
  validates :marketable, inclusion: { in: [true, false] }

  has_many :steam_items

  def image_url(dim = "96fx96f")
    "https://community.fastly.steamstatic.com/economy/image/#{icon_url}/#{dim}"
  end

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

  def self.assign_name_ids
    self.where(item_nameid: nil).each do |steam_item_data|
      begin
        steam_item_data.get_nameid
      rescue RateLimitError => e
        p "Retrying in 2 min"
        sleep(120)
        steam_item_data.get_nameid
      end
      sleep(10)
    end
  end

  def get_nameid
    response = HTTParty.get(market_page_url)
    if response.success?
      html = response.body
      doc = Nokogiri::HTML(html)

      name_id = nil
      doc.css('script').each do |script_tag|
        match = script_tag.content.match(/Market_LoadOrderSpread\(\s*(\d+)\s*\)/)
        if match
          name_id = match[1].to_i
          break
        end
      end

      if name_id
        update(item_nameid: name_id)
      else
        raise StandardError.new("No ID found for record #{id}")
      end
    else
      raise RateLimitError if response.code == 429
      raise StandardError.new("#{response.code} error for record #{id}")
    end
  end

  def self.assign_values
    self.where(average_price: nil).each do |steam_item_data|
      begin
        steam_item_data.get_current_value
      rescue RateLimitError => e
        p "Retrying in 2 min"
        sleep(120)
        steam_item_data.get_current_value
      end
      sleep(5)
    end
  end

  def market_hash_name
    ERB::Util.url_encode(name.gsub("/", "-"))
  end

  def market_history_url
    "https://steamcommunity.com/market/pricehistory/?appid=218620&market_hash_name=#{market_hash_name}"
  end

  def market_page_url
    "https://steamcommunity.com/market/listings/218620/#{market_hash_name}"
  end

  def get_current_value
    get_history_data
    value_from_history
  end

  def get_history_data
    request_data = JSON.parse(File.read("market_history_req_headers.json"))

    @response = HTTParty.get(
      "#{request_data["url"]}&market_hash_name=#{market_hash_name}",
      headers: request_data["headers"]
    )

    if @response.code == 429
      raise ExpiredCredentialsError, "Credentials Expired"
    end

    raise SteamApiError, "#{id} failed: #{@response.code}" unless @response.ok?
  end

  def value_from_history
    data = JSON.parse(@response.body)
    raise SteamApiError, "#{id} failed, used wrong currency (#{data["price_prefix"]}:#{data["price_suffix"]})" unless data["price_suffix"] == "руб."

    sale_prices = data["prices"]

    recent_sales = sale_prices.filter do |sale_data|
      time_stamp = sale_data.first.gsub(": +0", " +0000")
      time = Time.strptime(time_stamp, "%b %d %Y %H %z")
      if marketable
        time > Time.now - 2.years
      else
        ((Time.now - 2.years) .. (Time.now - 1.year)).cover?(time)
      end
    end

    update(average_price: 0) && return unless recent_sales.present?

    all_sale_prices = recent_sales.reduce([]) do |total, sale|
      price = sale.second
      quantity = sale.third.to_i
      total += Array.new(quantity, price)
    end

    average_price = all_sale_prices.reduce(:+) / all_sale_prices.length

    all_sale_prices.sort!
    total_sales = all_sale_prices.length
    median_price = (all_sale_prices[(total_sales - 1) / 2] + all_sale_prices[total_sales / 2]) / 2.0

    update(average_price:, median_price:, lowest_price: all_sale_prices.first, highest_price: all_sale_prices.last)
  end
end

class RateLimitError < StandardError; end
class SteamApiError < StandardError; end
class ExpiredCredentialsError < StandardError; end