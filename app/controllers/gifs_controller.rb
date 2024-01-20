class GifsController < ApplicationController
  def show
    if request.user_agent.include?('Discordbot') || request.user_agent.include?('discordapp')
      send_file('app/assets/images/msga.gif', type: 'image/gif', disposition: 'inline')
    else
      redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
    end
  end
end