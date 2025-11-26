class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user! # Ensure only logged-in users can subscribe
  def new

  end
  def test
    @subscription = current_user.web_push_subscriptions.find(params[:id])

    message = {
      title: "Test Notification",
      body: "It works! Hello from Rails 8.",
      path: "/paths"
    }

    begin
      # CHANGED: WebPush -> Webpush
      Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: @subscription.endpoint,
        p256dh: @subscription.p256dh,
        auth: @subscription.auth,
        vapid: {
          subject: "mailto:admin@example.com",
          public_key: ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY']
        }
      )
      flash[:notice] = "Notification sent!"
      # CHANGED: WebPush -> Webpush
    rescue Webpush::InvalidSubscription => e
      @subscription.destroy
      flash[:alert] = "Subscription invalid - removed."
    rescue => e
      flash[:alert] = "Error: #{e.message}"
    end

    redirect_back(fallback_location: root_path)
  end
  def create
    # The browser sends:
    # {
    #   subscription: {
    #     endpoint: "...",
    #     keys: { p256dh: "...", auth: "..." }
    #   },
    #   device_name: "My MacBook"
    # }

    subscription_params = params.require(:subscription).permit(:endpoint, keys: [:p256dh, :auth])

    # We find or initialize by the 'endpoint' because that is the unique ID for a browser session.
    # If the user clears cookies/storage, the browser might generate a new endpoint.
    @subscription = current_user.web_push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    # Update the security keys and the device name
    @subscription.update(
      p256dh: subscription_params[:keys][:p256dh],
      auth: subscription_params[:keys][:auth],
      device_name: params[:device_name]
    )

    if @subscription.persisted?
      head :ok
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end
end