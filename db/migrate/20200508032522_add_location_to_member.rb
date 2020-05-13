class AddLocationToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :followed_location_ids, :integer, array: true
  end
end
