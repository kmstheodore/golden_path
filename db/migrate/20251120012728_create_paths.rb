class CreatePaths < ActiveRecord::Migration[8.0]
  def change
    create_table :paths do |t|
      t.string :name
      t.datetime :strike
      t.datetime :completed_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
