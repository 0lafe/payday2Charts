# Sending output to STDOUT for Docker
set :output, { standard: '/proc/1/fd/1', error: '/proc/1/fd/2' }
# TODO: Modify whenever's other job_types as needed, for now I'm only using rake
job_type :rake, "/rails/bin/cron_executor bundle exec rake :task :output"

every 1.minutes do
  rake "test:log"
end