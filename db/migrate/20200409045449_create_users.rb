class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :avatar
      t.integer :team_id
      t.integer :grade_id
      t.boolean :enabled
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
