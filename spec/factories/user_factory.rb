FactoryBot.define do
  factory :user do
    steam_id { "76561198043378601" }

    after(:create) do |user|
      create(:weapon_stat, user:)
      create(:player_stat, user:)
      create(:misc_stat, user:)
    end
  end
end
