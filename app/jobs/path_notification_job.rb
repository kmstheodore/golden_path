class PathNotificationJob < ApplicationJob
  queue_as :default

  def perform(path)
    # 1. Guard clause: If the path or subscription was deleted, stop.
    return unless path&.web_push_subscription

    # 2. Construct the payload
    message = {
      title: "Reminder: #{path.name}",
      body: "It's time! Your task is due.",
      path: "/paths" # Clicking the notification opens the list
    }

    # 3. Send the notification
    begin
      # FIXED: Changed WebPush -> Webpush (lowercase 'p' to match the gem)
      Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: path.web_push_subscription.endpoint,
        p256dh: path.web_push_subscription.p256dh,
        auth: path.web_push_subscription.auth,
        vapid: {
          subject: "mailto:admin@example.com",
          public_key: ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY']
        }
      )
      # FIXED: Changed WebPush -> Webpush here as well
    rescue Webpush::InvalidSubscription
      # Cleanup if the browser subscription is dead
      path.web_push_subscription.destroy
    rescue => e
      Rails.logger.error("PathNotificationJob Error: #{e.message}")
    end
  end
end