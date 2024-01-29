Rails.configuration.after_initialize do
  if defined?(::Rails::Server)
    UpdateLeaderboardJob.perform_async
  end
end
