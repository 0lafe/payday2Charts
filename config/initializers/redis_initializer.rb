Rails.configuration.after_initialize do
  if Rails.env == 'development'
    REDIS_CLIENT = Redis.new(host: 'localhost', port: 6379)
  else
    REDIS_CLIENT = Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  end
end