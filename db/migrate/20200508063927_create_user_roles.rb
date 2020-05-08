class CreateUserRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_roles do |t|
      t.references :user
      t.references :role

      t.timestamps
    end

    add_index(:user_roles, [:user_id, :role_id], :unique => true)
  end
end
