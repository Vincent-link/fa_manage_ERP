class AddBuIdToUsers < ActiveRecord::Migration[6.0]
  def change
  	add_column :users, :bu_id, :integer
  end
end
