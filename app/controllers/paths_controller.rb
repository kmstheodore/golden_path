class PathsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paths = current_user.paths.order(strike_time: :asc)
  end

  def new
    @path = current_user.paths.build
    # Get list of devices for the dropdown
    @devices = current_user.web_push_subscriptions.map { |sub| [sub.device_name, sub.id] }
  end

  def create
    @path = current_user.paths.build(path_params)

    if @path.save
      # --- Add this block ---
      if @path.web_push_subscription.present?
        # Schedule the job to run at the specific strike_time
        PathNotificationJob.set(wait_until: @path.strike_time).perform_later(@path)
      end
      # ----------------------

      redirect_to paths_path, notice: "Path created! (Notification scheduled)"
    else
      @devices = current_user.web_push_subscriptions.map { |sub| [sub.device_name, sub.id] }
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.paths.find(params[:id]).destroy
    redirect_to paths_path, notice: "Path removed."
  end

  private

  def path_params
    params.require(:path).permit(:name, :strike_time, :web_push_subscription_id)
  end
end