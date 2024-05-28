class DownloadGif < ApplicationRecord
  validates :title, :url, :name, presence: true

  before_destroy :delete_associated_gif

  after_save :create_gif, if: :saved_change_to_title?

  def create_gif
    return unless Rails.env == 'development'
    
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

    base_gif.write(Rails.root.join("app").join("assets").join("images").join("gifs").join("#{name}.gif"))
  end

  def gif_path
    Rails.root.join("app").join("assets").join("images").join("gifs").join("#{name}.gif")
  end

  def delete_associated_gif
    File.delete(gif_path) if File.exist?(gif_path)
  end
end
