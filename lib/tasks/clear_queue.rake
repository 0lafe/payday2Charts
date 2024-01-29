require 'sidekiq/api'

desc "Clears Sidekiq queue"
task :clear_queue do
  Sidekiq::Queue.all.each(&:clear)
  Sidekiq::RetrySet.new.clear
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::DeadSet.new.clear
end
