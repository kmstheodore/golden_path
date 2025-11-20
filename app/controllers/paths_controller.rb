class PathsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paths = current_user.paths.order(strike: :asc)
  end

  def new
    @path = current_user.paths.new
  end

  def create
    @path = current_user.paths.new(path_params)

    if @path.save
      redirect_to paths_path, notice: "Path created and scheduled!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def complete
    @path = current_user.paths.find(params[:id])
    @path.update(completed_at: Time.current)
    redirect_to paths_path, notice: "Path completed!"
  end

  private

  def path_params
    # Permit name, strike time, and the array of selected device IDs
    params.require(:path).permit(:name, :strike, device_ids: [])
  end
end
