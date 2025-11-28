class PathsController < ApplicationController
  before_action :authenticate_user!

  def new
    @path = current_user.paths.build
    # Existing: My devices
    @devices = current_user.web_push_subscriptions.map { |sub| [sub.device_name, sub.id] }

    # New: My Mutual Friends
    @friends = current_user.mutual_friends
  end

  def create
    @path = current_user.paths.build(path_params)

    if @path.save
      # Schedule if there is ANY recipient (Device OR Friend)
      if @path.web_push_subscriptions.any? || @path.shared_users.any?
        PathNotificationJob.set(wait_until: @path.strike_time).perform_later(@path)
      end

      redirect_to root_path, notice: "Path created! (Notification scheduled)"
    else
      @devices = current_user.web_push_subscriptions.map { |sub| [sub.device_name, sub.id] }
      @friends = current_user.mutual_friends
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.paths.find(params[:id]).destroy
    redirect_to paths_path, notice: "Path removed."
  end

  def mark_as_done
    # Use current_user.paths.find to ensure the user owns this path
    @path = current_user.paths.find(params[:id])

    if @path.update(done_at: Time.current)
      flash[:notice] = "\"#{@path.name}\" marked as done! 🎉"
    else
      flash[:alert] = "Failed to mark \"#{@path.name}\" as done."
    end
    # Redirect to the dashboard root path
    redirect_to authenticated_root_path
  end

  private

  def path_params
    # Added shared_user_ids: []
    params.require(:path).permit(:name, :strike_time, web_push_subscription_ids: [], shared_user_ids: [])
  end
end