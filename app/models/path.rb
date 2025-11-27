class Path < ApplicationRecord
  belongs_to :user

  # CHANGED: Replaced 'belongs_to' with 'has_and_belongs_to_many'
  has_and_belongs_to_many :web_push_subscriptions

  validates :name, :strike_time, presence: true
end