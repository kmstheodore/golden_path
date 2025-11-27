class PathNotificationJob < ApplicationJob
  queue_as :default

  def perform(path)
    # 1. Guard clause: Stop if path is gone
    return unless path

    # 2. Construct the payload (same for all devices)
    message = {
      title: "Reminder: #{path.name}",
      body: "It's time! Your task is due.",
      path: "/paths"
    }

    # 3. Iterate over ALL linked subscriptions
    path.web_push_subscriptions.each do |subscription|
      begin
        Webpush.payload_send(
          message: JSON.generate(message),
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          vapid: {
            subject: "mailto:admin@example.com",
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY']
          }
        )
      rescue Webpush::InvalidSubscription
        # Remove only the dead subscription
        subscription.destroy
      rescue => e
        Rails.logger.error("PathNotificationJob Error for Device #{subscription.device_name}: #{e.message}")
      end
    end
  end
end