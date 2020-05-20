class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.text :desc
      t.integer :user_id
      t.integer :funding_id

      t.timestamps
    end

    add_index :questions, :user_id
    add_index :questions, :funding_id
  end
end
