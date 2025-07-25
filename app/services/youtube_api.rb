class YoutubeApi
  def self.get_avatars(ids)
    response = HTTParty.get(
      "https://www.googleapis.com/youtube/v3/channels?id=#{ids.join(",")}&part=snippet&key=#{Rails.application.credentials.youtube}"
    )
    JSON.parse(response.body)
  end
end