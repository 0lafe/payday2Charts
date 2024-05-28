class AddNameToDownloadGif < ActiveRecord::Migration[7.0]
  def change
    add_column :download_gifs, :name, :string, null: false
  end
end
