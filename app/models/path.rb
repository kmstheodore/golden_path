class Path < ApplicationRecord
  belongs_to :user
  belongs_to :web_push_subscription, optional: true # Optional means "Send to all" logic later
  belongs_to :user
  validates :name, :strike_time, presence: true
end