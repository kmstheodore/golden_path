class CreateJoinTablePathsWebPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    # 1. Create the join table
    create_join_table :paths, :web_push_subscriptions do |t|
      t.index [:path_id, :web_push_subscription_id], name: 'index_path_subs_on_path_and_sub'
      t.index [:web_push_subscription_id, :path_id], name: 'index_path_subs_on_sub_and_path'
    end

    # 2. Remove the old single-device column from paths
    remove_reference :paths, :web_push_subscription, foreign_key: true
  end
end