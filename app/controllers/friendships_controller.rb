class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    friend = User.find_by(email: params[:email])

    if friend && friend != current_user
      current_user.friendships.find_or_create_by(friend: friend)
      flash[:notice] = "Added #{friend.email}!"
    else
      flash[:alert] = "User not found."
    end
    redirect_back(fallback_location: root_path)
  end

  def destroy
    current_user.friendships.find(params[:id]).destroy
    redirect_back(fallback_location: root_path)
  end
end