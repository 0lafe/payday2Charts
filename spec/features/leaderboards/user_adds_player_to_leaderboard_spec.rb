require "rails_helper"

feature "User adds player to LB" do

  before(:each) do
    visit leaderboards_path
  end

  context "When adding a player to the leaderboards" do
    scenario "A real player will be accepted" do
      fill_in "Steam 64 ID", with: "76561198043378601"
      click_button "Add Player To Leaderboard"
    end
  end
end