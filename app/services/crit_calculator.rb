class CritCalculator
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
