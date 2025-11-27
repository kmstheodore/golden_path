class Path < ApplicationRecord
  belongs_to :user

  # Direct devices (my own devices I selected)
  has_and_belongs_to_many :web_push_subscriptions

  # Shared people (friends I selected)
  has_many :path_shares, dependent: :destroy
  has_many :shared_users, through: :path_shares, source: :user

  validates :name, :strike_time, presence: true
  validate :shared_users_must_be_mutual

  private

  def shared_users_must_be_mutual
    # If we have shared users, check if they are all in the creator's mutual_friends list
    if shared_users.any?
      unless (shared_users - user.mutual_friends).empty?
        errors.add(:shared_users, "can only include mutual friends")
      end
    end
  end
end