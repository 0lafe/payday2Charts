class CreateApiLog < ActiveRecord::Migration[8.0]
  def change
    create_table :api_logs do |t|
      t.string :resource
      t.text :params
      t.integer :code
      t.timestamps
    end
  end
end
