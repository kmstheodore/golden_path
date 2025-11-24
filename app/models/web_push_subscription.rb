class WebPushSubscription < ApplicationRecord
  belongs_to :user
  has_many :paths, dependent: :nullify

  validates :endpoint, :p256dh, :auth, presence: true
  validates :device_name, presence: true
end
