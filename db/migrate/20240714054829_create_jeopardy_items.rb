class CreateJeopardyItems < ActiveRecord::Migration[7.0]
  def change
    create_table :jeopardy_games do |t|
      t.string :name
      t.timestamps
    end

    create_table :jeopardy_categories do |t|
      t.string :title
      t.belongs_to :jeopardy_game
    end

    create_table :jeopardy_questions do |t|
      t.belongs_to :jeopardy_category
      t.text :question
      t.text :answer
      t.integer :value
      t.boolean :answered, default: false
    end

    create_table :jeopardy_players do |t|
      t.string :name
      t.belongs_to :jeopardy_game
      t.integer :score, default: 0
      t.timestamps
    end
  end
end
