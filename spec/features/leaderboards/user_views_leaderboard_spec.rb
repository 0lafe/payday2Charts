require 'rails_helper'

RSpec.feature "Get Charts" do
  let!(:user) { FactoryBot.create(:user) }
  let!(:user_2) { FactoryBot.create(:user, steam_id: "76561198151801971") }

  before(:each) do
    visit leaderboards_path
  end

  context "When a user views leaderboards" do
    scenario "they see players" do
      select2_select("#stat-choice", "CAR-4 Rifle")
      expect(page).to have_content("0lafe")
    end

    scenario "the records order correctly" do
      select2_select("#stat-choice", "CAR-4 Rifle")
      table = read_table("#leaderboard-table")
      expect(table[0]["Kills"]).to be >= table[1]["Kills"]
    end

    scenario "you can select different stats on weapons" do
      select2_select("#stat-choice", "CAR-4 Rifle")
      click_button "Uses"
      table = read_table("#leaderboard-table")
      expect(table[0]["Uses"]).to be >= table[1]["Uses"]
    end
  end
end
