class CreatePaths < ActiveRecord::Migration[8.1]
  def change
    create_table :paths do |t|
      t.string :name
      t.datetime :strike_time
      t.references :user, null: false, foreign_key: true

      t.references :web_push_subscription, null: true, foreign_key: true


      t.timestamps
    end
  end
end
