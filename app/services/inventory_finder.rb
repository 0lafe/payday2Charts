class InventoryFinder
  attr_accessor :expired_credentials

  PROXY_HOST = Rails.application.credentials.dig("proxy", "host")
  PROXY_PORT = Rails.application.credentials.dig("proxy", "port")
  PROXY_USER = Rails.application.credentials.dig("proxy", "user")
  PROXY_PASSWORD = Rails.application.credentials.dig("proxy", "password")

  CONCURRENT_REQUESTS = 5

  def self.import_users_to_migrate
    people = JSON.parse(File.read("total_people.json"))

    people.each_slice(1000).each_with_index do |slice, index|
      p index
      UsersToImport.insert_all(
        slice.map do |user|
          {
            steam_id: user
          }
        end
      )
    end
  end

  def self.grab_inventories
    expired_credentials = false
    people = UsersToImport.waiting.limit(CONCURRENT_REQUESTS)

    while people.present? do
      imports = []

      Async do |parent|
        tasks = people.map do |user_to_import|
          parent.async do
            begin
              imports << new(user_to_import)
            rescue ExpiredCredentialsError
              expired_credentials = true
            end
          end
        end

        tasks.compact.each(&:wait)
      end

      raise SteamApiError, "Expired Credentials" if expired_credentials

      imports.each(&:persist_data)
      people = UsersToImport.waiting.limit(CONCURRENT_REQUESTS)
    end

    p "Done :)"
  end

  def initialize(user_to_import)
    @user_to_import = user_to_import
    @steam_id = @user_to_import.steam_id
    @inventory = []
    @data = JSON.parse(File.read("inventory_req_headers.json"))
    @start = 0
    
    p "#{@user_to_import.id} - #{@user_to_import.steam_id}"

    get_data
  end
  
  def persist_data
    user = User.find_or_create_by(steam_id: @steam_id)
    inserts = @inventory.map do |item|
      {
        user_id: user.id,
        class_id: item[:class_id],
        amount: item[:amount]
      }
    end

    user.steam_items.destroy_all
    SteamItem.insert_all(inserts)
    @user_to_import.complete
  end

  private

  def get_data
    get_reply
    process_response

    unless no_inventory? || @expired_credentials
      handle_more if @response["more"]
    end
  end

  def process_data
    @response["rgInventory"].each do |item|
      class_id = item[1]["classid"]
      amount = item[1]["amount"].to_i

      @inventory << {
        class_id:,
        amount:
      }
    end
  end

  def is_private?
    @response.is_a?(Array) && @response[0] == "success" && @response[1] == false
  end

  def no_inventory?
    is_private? || @response["rgInventory"] == false
  end

  def get_reply
    url = if @start == 0
      URI("#{@data["url"]}&partner=#{@steam_id}")
    else
      URI("#{@data["url"]}&partner=#{@steam_id}&start=#{@start}")
    end

    req = Net::HTTP::Get.new(url)

    @data["headers"].keys.each do |header_key|
      req[header_key] = @data["headers"][header_key]
    end

    proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT, PROXY_USER, PROXY_PASSWORD)
    @reply = proxy.start(url.host, url.port, use_ssl: true) do |http|
      http.request(req)
    end

    if @reply.kind_of? Net::HTTPUnauthorized
      raise ExpiredCredentialsError, "Credentials Expired"
    end

    raise SteamApiError, "#{@user_to_import.id} failed: #{@reply.class}" unless @reply.kind_of? Net::HTTPSuccess
  end

  def process_response
    if @reply["Content-Encoding"] == "gzip"
      sio = StringIO.new(@reply.body)
      gz = Zlib::GzipReader.new(sio)
      decompressed = gz.read
      @response = JSON.parse(decompressed)
    else
      raise SteamApiError, "#{@user_to_import.id} failed, wrong encoding format"
    end

    process_data unless no_inventory? || @expired_credentials
  end

  def handle_more
    while @response["more"]
      @start = @response["more_start"]
      get_reply
      process_response
    end
  end
end

class SteamApiError < StandardError; end

class ExpiredCredentialsError < StandardError; end