require 'rails_helper'

RSpec.feature "Get Charts" do

  before(:each) do
    visit root_path
    expect(page).to have_selector(".chart-description") # wait for charts to load in
  end

  context "When a user views charts" do
    scenario "They see the melee chart" do
      expect(page).to have_content("Melee Kills")
      expect(page).to have_selector(".data-table", count: 6)
    end

    scenario "They can scroll" do
      find('#next-button').click
      expect(page).to have_content("#7 Overall")
      expect(page).to have_content("#12 Overall")
    end

    scenario "They can search for melee weapons", js: true do
      fill_in "search_field", with: "Two Handed Great Ruler"
      expect(page).to have_selector(".data-table", count: 1)
      expect(page).to have_content("Two Handed Great Ruler")
    end

    scenario "They can change the viewed statistic" do
      select2_select(".select2", "Perkdeck Used")
      expect(page).to have_content(" (Deck)")
    end
  end
end
