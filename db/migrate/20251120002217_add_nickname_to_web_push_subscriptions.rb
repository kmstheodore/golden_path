class AddNicknameToWebPushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :web_push_subscriptions, :nickname, :string
  end
end
