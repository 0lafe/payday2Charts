class CreateDraftGames < ActiveRecord::Migration[8.0]
  def change
    create_table :draft_games do |t|
      t.belongs_to :user
      t.timestamps
      t.string :public_key
      t.integer :stage, null: false, default: 0

      t.text :base_heists, array: true, null: false, default: []
      t.integer :heist_ban_count, null: false, default: 2
      t.string :heist

      t.text :base_perkdecks, array: true, null: false, default: []
      t.integer :perkdeck_ban_count, null: false, default: 2

      t.text :base_weapons, array: true, null: false, default: []
      t.integer :weapon_ban_count, null: false, default: 2
    end

    add_index :draft_games, :public_key, unique: true

    create_table :draft_game_users do |t|
      t.belongs_to :user, null: false
      t.belongs_to :draft_game, null: false
      t.integer :team, null: false
    end

    create_table :draft_bans do |t|
      t.belongs_to :draft_game
      t.belongs_to :draft_game_user
      t.integer :draft_type, null: false

      t.string :name, null: false
    end

    create_table :draft_choices do |t|
      t.belongs_to :draft_game
      t.belongs_to :draft_game_user
      t.integer :draft_type, null: false

      t.string :name, null: false
    end
  end
end
