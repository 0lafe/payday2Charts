# Sending output to STDOUT for Docker
set :output, { standard: '/proc/1/fd/1', error: '/proc/1/fd/2' }

every 1.minutes do
  rake "test:log"
end