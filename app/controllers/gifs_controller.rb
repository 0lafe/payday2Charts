class GifsController < ApplicationController
  def index

  end
  
  def show
    # @gif = DownloadGif.find(params[:id])
    @gif = DownloadGif.find_by(name: params[:id])

    if true || request.user_agent.include?('Discordbot') || request.user_agent.include?('discordapp') || request.user_agent.include?('Mozilla/5.0 (Macintosh; Intel Mac OS X 11.6; rv:92.0) Gecko/20100101 Firefox/92.0')
      send_file(@gif.gif_path, type: 'image/gif', disposition: 'inline')
    else
      redirect_to @gif.url, allow_other_host: true
    end
  end
end