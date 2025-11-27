class PagesController < ApplicationController
  def home
    if current_user.web_push_subscriptions.empty?
      redirect_to new_web_push_subscription_path
    end
    @paths = (current_user.paths + current_user.shared_paths).sort_by(&:strike_time)
  end

  def welcome

  end
end
