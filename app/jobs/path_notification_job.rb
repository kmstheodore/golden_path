class PathNotificationJob < ApplicationJob
  queue_as :default

  def perform(path)
    return unless path

    message = {
      title: "Reminder: #{path.name}",
      body: "It's time! Your task is due.",
      path: "/paths"
    }

    # 1. Get Creator's selected devices
    my_subs = path.web_push_subscriptions

    # 2. Get Shared Friends' devices
    #    We look up all subscriptions belonging to the users this path is shared with
    friend_subs = WebPushSubscription.where(user_id: path.shared_user_ids)

    # 3. Combine and Deduplicate
    all_subscriptions = (my_subs + friend_subs).uniq

    # 4. Notify everyone
    all_subscriptions.each do |subscription|
      begin
        WebPush.payload_send(
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
      rescue WebPush::ExpiredSubscription
        subscription.destroy
      rescue => e
        Rails.logger.error("PathNotificationJob Error for Device #{subscription.device_name}: #{e.message}")
      end
    end
  end
end