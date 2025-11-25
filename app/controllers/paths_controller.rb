class PathsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paths = current_user.paths.order(strike_time: :asc)
  end

  def new
    @path = current_user.paths.build
    # Load subscriptions for the dropdown
    @devices = current_user.web_push_subscriptions.map { |sub| [sub.device_name, sub.id] }
  end

  def create
    @path = current_user.paths.build(path_params)

    if @path.save
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
    # Allow the user to select a specific subscription ID
    params.require(:path).permit(:name, :strike_time, :web_push_subscription_id)
  end
end