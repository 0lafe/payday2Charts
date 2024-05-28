class DownloadGif < ApplicationRecord
  validates :title, :url, presence: true

  has_one_attached :gif, dependent: :destroy

  after_save :create_gif, if: :saved_change_to_title?

  def create_gif
    base_gif = Magick::ImageList.new("app/assets/images/msga.gif")

    text = Magick::Draw.new

    base_gif.each do |frame|
      frame.annotate(text, 0, 0, 1, 1, title) do
        text.gravity = Magick::NorthGravity
        text.pointsize = 32
        text.font_weight = 700
        text.fill = "#000000"
        frame.format = "gif"
      end
      frame.annotate(text, 0, 0, -1, -1, title) do
        text.gravity = Magick::NorthGravity
        text.pointsize = 32
        text.font_weight = 700
        text.fill = "#ffffff"
        frame.format = "gif"
      end
    end

    gif.attach io: StringIO.open(base_gif.to_blob), filename: "gif#{id}.gif", content_type: 'image/gif'
  end
end
