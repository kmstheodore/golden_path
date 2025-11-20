class Path < ApplicationRecord
  belongs_to :user

  # Link to the devices
  has_many :path_devices, dependent: :destroy
  has_many :devices, through: :path_devices, source: :web_push_subscription

  validates :name, presence: true
  validates :strike, presence: true

  # Trigger the scheduling immediately after creating the record
  after_create_commit :schedule_notification

  def completed?
    completed_at.present?
  end

  private

  def schedule_notification
    # Queue the job to run at the specific 'strike' time
    PathNotificationJob.set(wait_until: strike).perform_later(self)
  end
end
