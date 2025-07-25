class UsersToImport < ActiveRecord::Migration[8.0]
  def change
    create_table :users_to_imports do |t|
      t.string :steam_id, null: false
      t.string :status, null: false, default: "waiting"
    end
  end
end
