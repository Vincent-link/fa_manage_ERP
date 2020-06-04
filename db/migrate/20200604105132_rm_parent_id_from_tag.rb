class RmParentIdFromTag < ActiveRecord::Migration[6.0]
  def change
    remove_column :tags, :parent_id
  end
end
