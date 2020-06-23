class AddBscStatusToFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :bsc_status, :integer
  end
end
