class NotificationBanner < ApplicationRecord
  validates :notification_type, presence: true
  validates :content, presence: true
end