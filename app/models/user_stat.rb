class UserStat < ApplicationRecord
  belongs_to :user
  belongs_to :stat
end