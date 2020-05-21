class RemoveDismiss < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :is_dismiss
  end
end
