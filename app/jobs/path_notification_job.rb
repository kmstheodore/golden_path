class PathNotificationJob < ApplicationJob
  queue_as :default

  def perform(path)
    # 1. Stop if path is deleted or already completed
    return if path.nil? || path.completed?

    # 2. Prepare the payload
    payload = JSON.generate({
      title: "Path Reminder: #{path.name}",
      body: "It is time for #{path.name}. Click to view.",
      path: "/paths"
    })

    # 3. Send to all selected devices
    path.devices.each do |device|
      begin
        WebPush.payload_send(
          message: payload,
          endpoint: device.endpoint,
          p256dh: device.p256dh_key,
          auth: device.auth_key,
          vapid: {
            subject: Rails.application.credentials.web_push[:email],
            public_key: Rails.application.credentials.web_push[:public_key],
            private_key: Rails.application.credentials.web_push[:private_key]
          }
        )
      rescue WebPush::InvalidSubscription
        device.destroy
      end
    end
  end
end
