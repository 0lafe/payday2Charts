require 'rails_helper'

RSpec.feature "Get Charts" do
  context "When a user views charts" do
    scenario "They see the melee chart" do
      visit "/"
    end
  end
end
