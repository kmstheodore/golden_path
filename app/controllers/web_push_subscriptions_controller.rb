class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    subscription_params = params.require(:subscription).permit(:endpoint, keys: [ :p256dh, :auth ])

    # Save the subscription to the database associated with the current user
    current_user.web_push_subscriptions.find_or_create_by(
      endpoint: subscription_params[:endpoint],
      p256dh_key: subscription_params[:keys][:p256dh],
      auth_key: subscription_params[:keys][:auth]
    )

    head :ok
  end
  def test_notification
    # Find the user's most recent device
    sub = current_user.web_push_subscriptions.last

    if sub
      # Send a payload to the browser
      WebPush.payload_send(
        message: JSON.generate({ title: "Hello!", body: "This is a test push from Golden Path.", path: "/" }),
        endpoint: sub.endpoint,
        p256dh: sub.p256dh_key,
        auth: sub.auth_key,
        vapid: {
          subject: Rails.application.credentials.web_push[:email],
          public_key: Rails.application.credentials.web_push[:public_key],
          private_key: Rails.application.credentials.web_push[:private_key]
        }
      )
      redirect_back fallback_location: root_path, notice: "Notification sent!"
    else
      redirect_back fallback_location: root_path, alert: "No device registered."
    end
  rescue WebPush::InvalidSubscription
    # If the browser rejects it (e.g. user revoked permission), delete the record
    sub&.destroy
    redirect_back fallback_location: root_path, alert: "Subscription expired."
  end
end
