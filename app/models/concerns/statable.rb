module Statable
  extend ActiveSupport::Concern

  class_methods do
    def get_top_100(name)
      return [] unless column_names.include?(name)

      stats = includes(:user)
        .where.not(user: { banned: true })
        .where.not({name => nil})
        .order("#{name} DESC")
        .limit(100)
        .select(
          :user_id,
          :updated_at,
          name
        )
        
      names = SteamApi.get_multiple_user_data(
        stats.map { |player|
          player.user.steam_id
        }
      )
      
      stats.map.with_index do |a, index|
        {
          name: names[index][:name],
          avatar: names[index][:avatar],
          steam_id: a.user.steam_id,
          value: a[name],
          updated_at: a.updated_at
        }
      end
    end
  end
end