class GifsController < ApplicationController
  def show
    if request.user_agent.include?('Discordbot') || request.user_agent.include?('discordapp') || request.user_agent.include?('Mozilla/5.0 (Macintosh; Intel Mac OS X 11.6; rv:92.0) Gecko/20100101 Firefox/92.0')
      send_file('app/assets/images/msga.gif', type: 'image/gif', disposition: 'inline')
    else
      case params[:id]
      when '1'
        redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
      when '2'
        redirect_to 'https://cdn.discordapp.com/attachments/997660569224085524/1244753340412203098/event_moment.rar?ex=66564262&is=6654f0e2&hm=b0a11e8fba9b8c182d49c46e9dff22b8c4fb6776772cbabeade949a490e6210f&', allow_other_host: true
      end
    end
  end
end