class CreateKpiGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :kpi_groups do |t|
      t.string :name
      t.integer :team_id

      t.timestamps
    end
  end
end
