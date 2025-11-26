class PagesController < ApplicationController
  def home
    if current_user.web_push_subscriptions.empty?
      redirect_to new_web_push_subscription_path
    end
    @paths = current_user.paths.order(strike_time: :asc)
  end

  def welcome

  end
end
