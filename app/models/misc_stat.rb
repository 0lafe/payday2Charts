class MiscStat < ApplicationRecord
  include Statable
  
  belongs_to :user

  def total_heists
    sum = 0
    column_names.each do |name|
      sum += user.misc_stat[name] if name.include?('contract_') && user.misc_stat[name] && name.include?('_win')
    end
    p sum
  end

  def perkdeck_list
    23.times.map do |i|
      {
        name: "specialization_used_#{i + 1}",
        value: self["specialization_used_#{i + 1}"]
      }
    end
  end
end
