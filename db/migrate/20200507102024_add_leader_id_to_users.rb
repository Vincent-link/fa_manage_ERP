class AddLeaderIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :leader_id, :integer
  end
end
