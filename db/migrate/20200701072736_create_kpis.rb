class CreateKpis < ActiveRecord::Migration[6.0]
  def change
    create_table :kpis do |t|
      t.integer :kpi_type
      t.integer :coverage
      t.integer :value
      t.string :desc
      t.string :relation
      t.integer :parent_id
      t.integer :kpi_group_id

      t.timestamps
    end
  end
end
