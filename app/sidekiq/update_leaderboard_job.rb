class UpdateLeaderboardJob
  include Sidekiq::Job

  def perform(*args)
    REDIS_CLIENT.set('lb', Leaderboard.create.to_json)
  end
end
