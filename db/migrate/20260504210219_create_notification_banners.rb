class CreateNotificationBanners < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_banners do |t|
      t.timestamps
      t.string :notification_type, null: false
      t.text :content, null: false
    end
  end
end
