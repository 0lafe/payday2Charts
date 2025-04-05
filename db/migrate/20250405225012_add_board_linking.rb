class AddBoardLinking < ActiveRecord::Migration[8.0]
  def change
    add_column :jeopardy_games, :next_game_id, :integer
  end
end
