class CreateEvaluations < ActiveRecord::Migration[6.0]
  def change
    create_table :evaluations do |t|
      t.integer :market
      t.integer :business
      t.integer :team
      t.integer :exchange
      t.boolean :is_agree
      t.string :other
      t.integer :user_id
      t.integer :funding_id

      t.timestamps
    end
    add_index :evaluations, :user_id
    add_index :evaluations, :funding_id
  end
end
