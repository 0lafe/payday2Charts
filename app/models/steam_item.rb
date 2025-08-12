class SteamItem < ApplicationRecord
  belongs_to :user
  belongs_to :steam_item_data

  validates :class_id, presence: true
  validates :amount, presence: true

  def self.total_items
    all.sum(:amount)
  end
end
