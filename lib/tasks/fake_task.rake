namespace :test do
  task log: :environment do
      puts "[#{DateTime.now}]\tRunning from Cron!"
  end
end