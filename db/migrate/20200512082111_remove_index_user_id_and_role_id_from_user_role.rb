class RemoveIndexUserIdAndRoleIdFromUserRole < ActiveRecord::Migration[6.0]
  def change
  	remove_index :user_roles, [:user_id, :role_id]
  end
end
