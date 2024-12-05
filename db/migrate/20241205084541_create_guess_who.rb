class CreateGuessWho < ActiveRecord::Migration[7.0]
  def change
    create_table :guess_whos do |t|
      t.string :items, array:true, default: []
      t.string :game_type, presence: true
      t.timestamps
    end
  end
end
