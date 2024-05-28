class CreateDownloadGifs < ActiveRecord::Migration[7.0]
  def change
    create_table :download_gifs do |t|
      t.string :title, null: false
      t.text :url, null: false
      t.timestamps
    end
  end
end
