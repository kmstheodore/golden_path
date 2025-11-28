class PagesController < ApplicationController
  def home
    if current_user.web_push_subscriptions.empty?
      redirect_to new_web_push_subscription_path
    end

    # MODIFIED: Filter out paths where done_at is NOT nil
    my_active_paths = current_user.paths.where(done_at: nil)
    shared_active_paths = current_user.shared_paths.where(done_at: nil)

    @paths = (my_active_paths + shared_active_paths).sort_by(&:strike_time)
  end

  def welcome

  end
end
