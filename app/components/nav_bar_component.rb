class NavBarComponent < ViewComponent::Base
  def initialize(options, title = nil)
    @options = options
    @title = title
  end
end