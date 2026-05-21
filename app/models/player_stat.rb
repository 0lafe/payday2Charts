class PlayerStat < ApplicationRecord
  include Statable

  belongs_to :user
end