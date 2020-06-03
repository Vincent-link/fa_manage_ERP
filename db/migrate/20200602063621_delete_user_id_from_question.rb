class DeleteUserIdFromQuestion < ActiveRecord::Migration[6.0]
  def change
    remove_column :questions, :user_id
  end
end
