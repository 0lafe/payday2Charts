desc "Clears Sidekiq queue"
task init_lb: [ :environment  ] do
  UpdateLeaderboardJob.perform_async
end
