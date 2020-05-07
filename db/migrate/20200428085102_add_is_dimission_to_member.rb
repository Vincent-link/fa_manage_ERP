class AddIsDimissionToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :is_dimission, :boolean, index: true
  end
end
