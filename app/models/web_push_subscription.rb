class WebPushSubscription < ApplicationRecord
  belongs_to :user

  # Add these lines:
  has_many :path_devices, dependent: :destroy
  has_many :paths, through: :path_devices
end
