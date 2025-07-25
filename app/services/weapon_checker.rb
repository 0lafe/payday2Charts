class WeaponChecker
  attr_accessor :wins

  def initialize(a, b)
    @base_a = a
    @base_b = b
    @wins = []

    @enemies = [
      [480.0, 3.75, false, "Light"],
      [960.0, 3.75, false, "Heavy"],
      [1800.0, 3.75, true, "Special"],
      [3600.0, 11.25, true, "Cloaker"],
      [2480.0, 3.75, false, "Marshal Marksman"],
      [3840.0, 3.75, true, "Marshal Shield"],
    ]

    @impact = [
      1.0, 1.05, 1.15
    ]

    @overkill = [
      1.0, 1.75
    ]

    @underdog = [
      1.0, 1.15
    ]

    @zerk = [
      1.0, 1.4, 1.8, 2.0
    ]

    @hvt = [
      1.0, 1.15, 1.65
    ]
  end

  def calculate
    @impact.each do |impact|
      @overkill.each do |overkill|
        @underdog.each do |underdog|
          @zerk.each do |zerk|
            @hvt.each do |hvt|
              @enemies.each do |enemy|
                2.times do |i|
                  headshot = i%2 == 0
                  hvtable = enemy[2] ? hvt : 1
                  damage_mul = impact * overkill * underdog * zerk * 1.05 * hvtable * (headshot ? enemy[1] : 1)
                  base_a = (@base_a + 2) * damage_mul
                  base_b = @base_b * damage_mul

                  enemy_granule = enemy[0] / 512.0
                  granule_a = (base_a / enemy_granule).ceil * enemy_granule
                  granule_b = (base_b / enemy_granule).ceil * enemy_granule

                  shots_a = (enemy[0] / granule_a).ceil
                  shots_b = (enemy[0] / granule_b).ceil

                  if shots_b < shots_a
                    @wins << format_values(
                      impact,
                      overkill,
                      underdog,
                      zerk,
                      hvtable,
                      enemy[3],
                      headshot,
                      shots_a,
                      shots_b
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def format_values(impact, overkill, underdog, zerk, hvt, enemy, headshot, shots_a, shots_b)
    out = "#{shots_b} instead of #{shots_a} on a :#{enemy}: "

    attrs = []

    if headshot
      attrs << "With a Headshot"
    else
      attrs << "Without a headshot"
    end

    if impact > 1
      attrs << "With Impact #{impact == 1.15 ? "Aced" : "Basic"}"
    else
      attrs << "Without Impact"
    end

    if overkill > 1
      attrs << "With Overkill"
    else
      attrs << "Without Overkill"
    end

    if underdog > 1
      attrs << "With Underdog"
    else
      attrs << "Without Underdog"
    end

    if zerk > 1
      attrs << "With #{zerk}% zerk"
    else
      attrs << "Without zerk"
    end
    
    if hvt > 1
      attrs << "With #{hvt} HVT"
    else
      attrs << "Without HVT"
    end

    out += attrs.to_sentence
  end
end