class TileComponent < ViewComponent::Base
  def initialize(title: nil, classes: "")
    @classes = classes
    @title = title
  end
end
