class RemoveBscStatusFromFunding < ActiveRecord::Migration[6.0]
  def change
    remove_column :fundings, :bsc_status
  end
end
