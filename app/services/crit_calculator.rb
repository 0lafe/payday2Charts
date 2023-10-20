class CritCalculator
  def initialize(params)
    @crit_mul = params[:crit_mul].to_f
    @enemy_health = params[:enemy_health].to_f
    @weapon_damage = params[:base_weapon_damage].to_f
    @weapon_damage *= params[:headshot_mul].to_f if params[:headshot_mul] && params[:headshot_mul].length.positive?
    @weapon_damage *= params[:additional_mul].to_f if params[:additional_mul] && params[:additional_mul].length.positive?
  end
 
  def combination_calc(c, h)
    h = [h, 0].max
    Math.gamma(c + h + 1) / (Math.gamma(c + 1) * Math.gamma(h + 1))
  end
 
  def check_crit(crit_chance)
    max_shots = (@enemy_health / @weapon_damage).ceil.to_i

    crits = 0
    carry = 0
    shots = 0
    hits = max_shots - 1

    distribution = []

    while hits >= 0
      current_shots = crits + hits + 1
      count = combination_calc(crits, hits)
      c_count = crits + 1
      scaled_probability = count * crit_chance ** (c_count) * (1.0 - crit_chance) ** (hits)

      if carry == 0 && hits > 0
        count = combination_calc(crits, hits + 1)
        scaled_probability += count * crit_chance ** (crits) * (1.0 - crit_chance) ** (hits + 1)
      end

      if carry == 0 && hits == 0 && (@enemy_health - @weapon_damage * @crit_mul * (c_count - 1)) <= @weapon_damage
        count = combination_calc(crits, 1)
        scaled_probability += count * crit_chance ** (crits) * (1.0 - crit_chance)
      end

      shots += scaled_probability * current_shots

      distribution << [current_shots, scaled_probability]
 
      hits -= 1
      carry += 1
      if carry == (@crit_mul - 1)
        carry = 0
        if (hits > 0)
          crits += 1
          hits -= 1
        end
      end
    end
 
    {
      shots: shots,
      distribution: distribution
    }
  end
 
  def self.experimental_tester(health, chance, crit_mul, damage)
    shots_list = []
    1000000.times do
      damage_done = 0.0
      shots = 0
      while damage_done < health
        shots += 1
        if rand() <= chance
          damage_done += damage * crit_mul
        else
          damage_done += damage
        end
      end
      shots_list << shots
    end
    shots_list.sum(0.0) / shots_list.size
  end
end
