class DownloadGif < ApplicationRecord
  validates :title, :url, presence: true

  after_save :create_gif
  before_destroy :delete_gif

  def create_gif
    base_gif = Magick::ImageList.new("app/assets/images/msga.gif")

    text = Magick::Draw.new

    base_gif.each do |frame|
      frame.annotate(text, 0, 0, 0, 0, title) do
        text.gravity = Magick::NorthGravity
        text.pointsize = 32
        text.font_weight = 700
        text.fill = "#000000"
        frame.format = "gif"
      end
      frame.annotate(text, 0, 0, -2, -2, title) do
        text.gravity = Magick::NorthGravity
        text.pointsize = 32
        text.font_weight = 700
        text.fill = "#ffffff"
        frame.format = "gif"
      end
    end

    base_gif.write("app/assets/images/gifs#{id}.gif")
  end

  def delete_gif
    File.delete("app/assets/images/gifs#{id}.gif")
  end
end