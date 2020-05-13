class ChangeOrgColumns2 < ActiveRecord::Migration[6.0]
  def change
    rename_column :organizations, :invest_period_id, :invest_period
  end
end
