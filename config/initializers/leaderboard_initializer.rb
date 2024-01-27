Rails.configuration.after_initialize do
  Rails.application.leaderboard = Leaderboard.new
end
