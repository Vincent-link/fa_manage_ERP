class CreateFundings < ActiveRecord::Migration[6.0]
  def change
    create_table :fundings do |t|
      t.integer :company_id
      t.string :intro
      t.integer :status
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
