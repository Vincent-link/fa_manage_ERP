class AddIndexToUser < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :grade_id
  end
end
