class WebPushSubscription < ApplicationRecord
  belongs_to :user

  # CHANGED: Replaced 'has_many' with 'has_and_belongs_to_many'
  has_and_belongs_to_many :paths

  validates :endpoint, :p256dh, :auth, presence: true
  validates :device_name, presence: true
end