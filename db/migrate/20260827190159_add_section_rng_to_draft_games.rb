class AddSectionRngToDraftGames < ActiveRecord::Migration[8.0]
  def change
    add_column :draft_games, :rng_state, :jsonb, default: {}, null: false
    add_column :draft_games, :round_count, :integer, default: 3, null: false
    add_column :draft_games, :team_a_wins, :integer, default: 0, null: false
    add_column :draft_games, :team_b_wins, :integer, default: 0, null: false
  end
end
