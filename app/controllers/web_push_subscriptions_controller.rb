class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user! # Ensure only logged-in users can subscribe

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