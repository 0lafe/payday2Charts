class AddJeopardyPerms < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :can_host_jeopardy, :boolean, default: :false
  end
end
