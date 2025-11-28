class AddDoneAtToPaths < ActiveRecord::Migration[8.1]
  def change
    add_column :paths, :done_at, :datetime
  end
end