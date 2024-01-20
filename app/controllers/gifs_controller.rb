class GifsController < ApplicationController
  def index
    p request
    if true
      send_file('app/assets/images/favicon.png', type: 'image/png', disposition: 'inline')
    else
      redirect_to 'https://github.com/mrcreepysos/msga/archive/refs/heads/main.zip', allow_other_host: true
    end
  end
end