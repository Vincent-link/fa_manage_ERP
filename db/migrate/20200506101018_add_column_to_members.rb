class AddColumnToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :tag_ids, :integer, array: true
  end
end
