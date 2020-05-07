class MergeEcmGroupToInvestorGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :investor_groups, :sectors, :integer, array: true
    add_column :investor_groups, :deleted_at, :timestamp
    add_column :investor_groups, :type, :string, index: true

    drop_table :ecm_groups
  end
end
