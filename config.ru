# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

vals = WeaponStat.column_names.map do |column|
  stat = WeaponStat.where.not({column => nil}).order("#{column} DESC").first
  p "Stat: #{column}, ID: #{stat.user.steam_id}, Value: #{stat[column]}"
end
# p vals