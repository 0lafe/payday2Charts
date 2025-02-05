require 'rails_helper'

RSpec.feature "Get Charts" do

  before(:each) do
    visit root_path
  end

  context "When a user views charts" do
    scenario "They see the melee chart" do
      expect(page).to have_content("Melee Kills")
      expect(page).to have_selector(".data-table", count: 6)
    end

    scenario "They can search for melee weapons", js: true do
      find("#search_field").send_keys("Two Handed Great Ruler")
      select "Weapon Kills", from: "statistic_choice"
      expect(page).to have_selector(".data-table", count: 1)
      expect(page).to have_content("Two handed Great Ruler")
    end
  end
end
