class PagesController < ApplicationController
  def home
  end
  def about
  end
  def my_devices
    @subscriptions = current_user.web_push_subscriptions.order(created_at: :desc)
  end
end
