class ChangeInvestorGroup < ActiveRecord::Migration[6.0]
  def change
    rename_column :investor_groups, :sectors, :sector_ids
  end
end
