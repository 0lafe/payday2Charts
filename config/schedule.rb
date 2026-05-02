# Sending output to STDOUT for Docker
set :output, { standard: '/proc/1/fd/1', error: '/proc/1/fd/2' }

every 1.day, at: "12:00 am" do
  rake "init_lb"
end

every 1.day, at: "12:00 pm" do
  rake "init_lb"
end