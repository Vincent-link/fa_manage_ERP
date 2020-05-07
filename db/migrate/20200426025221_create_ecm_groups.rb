class CreateEcmGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :ecm_groups do |t|
      t.string :name
      t.integer :sectors, array: true
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
