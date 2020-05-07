class AddColumnToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :scale_ids, :integer, array: true
  end
end
