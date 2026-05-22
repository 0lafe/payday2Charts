class AddDisplayToStats < ActiveRecord::Migration[8.0]
  def change
    add_column :stats, :display, :boolean, default: true
  end
end
