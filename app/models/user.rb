class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :paths, dependent: :destroy
  has_many :web_push_subscriptions, dependent: :destroy

  # --- Social Features ---
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :path_shares, dependent: :destroy
  has_many :shared_paths, through: :path_shares, source: :path

  # A "mutual" friend is someone I have added AND who has added me back.
  # We only allow sharing paths with mutual friends to prevent spam.
  def mutual_friends
    friends.where(id: Friendship.where(friend_id: id).select(:user_id))
  end

  def pending_requests
    # Users who have added ME as a friend...
    requesters = User.joins(:friendships).where(friendships: { friend_id: id })

    # ...but whom I have NOT added back yet.
    requesters.where.not(id: friendships.select(:friend_id))
  end
end