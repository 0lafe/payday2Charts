require "rails_helper"

feature "User adds player to LB" do

  before(:each) do
    visit leaderboards_path
  end

  context "When adding a player to the leaderboards" do
    scenario "A real player will be accepted" do
      fill_in "Steam 64 ID", with: "76561198043378601"
      click_button "Add Player To Leaderboard"
      expect(page).to have_content("User added successfully")
    end

    scenario "an incorrect id will fail" do
      fill_in "Steam 64 ID", with: "1234"
      click_button "Add Player To Leaderboard"
      expect(page).to have_content("Error, make sure the ID is correct and the player's stats are public and try again")
    end

    scenario "non integar characters will get stripped" do
      fill_in "Steam 64 ID", with: "  76561198043378601asda"
      click_button "Add Player To Leaderboard"
      expect(page).to have_content("User added successfully")
      expect(User.last.steam_id).to eq("76561198043378601")
    end
  end
end