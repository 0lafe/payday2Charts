class SteamItem < ApplicationRecord
  belongs_to :user
  belongs_to :steam_item_data, foreign_key: :class_id, primary_key: :id

  validates :class_id, presence: true
  validates :amount, presence: true

  def self.total_items
    all.sum(:amount)
  end
end
