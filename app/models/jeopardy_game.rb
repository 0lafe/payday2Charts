class JeopardyGame < ApplicationRecord
  has_many :jeopardy_categories
  has_many :jeopardy_questions, through: :jeopardy_categories
  has_many :jeopardy_players

  accepts_nested_attributes_for :jeopardy_categories, reject_if: proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :jeopardy_players
end