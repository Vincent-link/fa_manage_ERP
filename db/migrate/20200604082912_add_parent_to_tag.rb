class AddParentToTag < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :parent_id, :integer
  end
end
