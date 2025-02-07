class NavBarComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(options, title = nil)
    @options = options
    @title = title
  end
end