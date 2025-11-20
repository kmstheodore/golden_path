class CreatePathDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :path_devices do |t|
      t.references :path, null: false, foreign_key: true
      t.references :web_push_subscription, null: false, foreign_key: true

      t.timestamps
    end
  end
end
