class AddKpiGroupIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :kpi_group_id, :integer
  end
end
