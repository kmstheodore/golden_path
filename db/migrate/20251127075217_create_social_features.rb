class CreateSocialFeatures < ActiveRecord::Migration[8.1]
  def change
    # 1. Track connections between users
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :friendships, [:user_id, :friend_id], unique: true

    # 2. Track which paths are shared with which users
    create_table :path_shares do |t|
      t.references :path, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # The recipient
      t.timestamps
    end
    add_index :path_shares, [:path_id, :user_id], unique: true
  end
end