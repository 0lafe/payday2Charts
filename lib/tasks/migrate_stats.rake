desc "Clears Sidekiq queue"
task migrate_stats: [ :environment ] do
  blacklist = ['id', 'user_id', 'created_at', 'updated_at']

  weapon_stats = (WeaponStat.column_names - blacklist).map do |stat|
    {
      stat_type: "weapon",
      name: stat,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  misc_stats = (MiscStat.column_names - blacklist).map do |stat|
    {
      stat_type: "misc",
      name: stat,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  player_stats = (PlayerStat.column_names - blacklist).map do |stat|
    {
      stat_type: "player",
      name: stat,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  Stat.insert_all(weapon_stats)
  Stat.insert_all(misc_stats)
  Stat.insert_all(player_stats)

  STAT_LOOKUP = Stat.pluck(:name, :id).to_h

  dedupe_records("weapon_stats")
  dedupe_records("player_stats")
  dedupe_records("misc_stats")
  
  insert_stats(WeaponStat)
  insert_stats(PlayerStat)
  insert_stats(MiscStat)
end

def insert_stats(model)
  size = model.count
  iteration = 1
  total = size / 1000 + 1

  model.find_in_batches(batch_size: 1000) do |stats|
    p "#{model.name} #{iteration}/#{total}"
    iteration += 1

    inserts = []

    stats.each do |stat|
      user_id = stat.user_id
      created_at = stat.created_at
      updated_at = stat.updated_at

      stat.attributes.each do |name, value|
        name = STAT_LOOKUP[name]

        next if value.nil? || name.nil?

        inserts << {
          user_id:,
          stat_id: name,
          value:,
          created_at:,
          updated_at:
        }
      end
    end

    inserts.each_slice(10000) do |slice|
      UserStat.insert_all!(slice)
    end
  end
end

def dedupe_records(name)
  sql = <<~SQL
    DELETE FROM #{name}
    WHERE id IN (
      SELECT id
      FROM (
        SELECT id,
              ROW_NUMBER() OVER (
                PARTITION BY user_id
                ORDER BY created_at DESC, id DESC
              ) AS rn
        FROM #{name}
      ) t
      WHERE t.rn > 1
    );
  SQL

  ActiveRecord::Base.connection.execute(sql)
end
