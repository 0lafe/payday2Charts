class JeopardyQuestion < ApplicationRecord
  belongs_to :jeopardy_category
  has_one :jeopardy_game, through: :jeopardy_category
  has_one_attached :image
end