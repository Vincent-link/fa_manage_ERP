class CreateRoleResources < ActiveRecord::Migration[6.0]
  def change
    create_table :role_resources do |t|
      t.integer :role_id
      t.string :name
      t.string :desc

      t.timestamps
    end

    add_index :role_resources, :role_id
    add_index :role_resources, :name
  end
end
