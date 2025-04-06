class JeopardyGame < ApplicationRecord
  attr_accessor :wager
  
  has_many :jeopardy_categories, dependent: :destroy
  has_many :jeopardy_questions, through: :jeopardy_categories, dependent: :destroy
  has_many :jeopardy_players, dependent: :destroy

  has_one :next_game, class_name: "JeopardyGame", foreign_key: "id", primary_key: "next_game_id"

  accepts_nested_attributes_for :jeopardy_categories, reject_if: proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :jeopardy_players

  def questions_left?
    jeopardy_questions.where(answered: false).present?
  end

  def move_players_to_next_game
    jeopardy_players.update_all(jeopardy_game_id: next_game_id)
  end
end