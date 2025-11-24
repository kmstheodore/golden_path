class CreateWebPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :web_push_subscriptions do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.string :device_name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
