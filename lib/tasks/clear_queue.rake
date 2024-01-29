require 'sidekiq/api'

desc "Clears Sidekiq queue"
task :clear_queue do
  Sidekiq::ScheduledSet.new.each do |job|
    job.delete
  end
end
