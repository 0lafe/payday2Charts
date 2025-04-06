class AddFinalJeopardy < ActiveRecord::Migration[8.0]
  def change
    add_column :jeopardy_games, :final_jeopardy, :boolean
  end
end
