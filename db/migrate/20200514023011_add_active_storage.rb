class AddActiveStorage < ActiveRecord::Migration[6.0]
  def change
    remove_column :organizations, :logo
    remove_column :users, :avatar
    remove_column :members, :card
    remove_column :members, :avatar
  end
end
