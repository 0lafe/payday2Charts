class AddMegaJacketMask < ActiveRecord::Migration[8.0]
  def change
    add_column :player_stats, :mask_used_mega_richard_returns, :integer
  end
end
