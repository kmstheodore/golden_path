class PagesController < ApplicationController
  before_action :authenticate_user!, only: [ :my_devices, :register_device ]
  def home
  end
  def about
  end
  def register_device
  end
  def my_devices
    @subscriptions = current_user.web_push_subscriptions.order(created_at: :desc)
  end
end
