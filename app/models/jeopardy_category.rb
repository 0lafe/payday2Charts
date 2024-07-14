class JeopardyCategory < ApplicationRecord
  belongs_to :jeopardy_game
  has_many :jeopardy_questions

  accepts_nested_attributes_for :jeopardy_questions, reject_if: proc { |attributes| attributes['question'].blank? }
end