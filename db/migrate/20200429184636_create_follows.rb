class CreateFollows < ActiveRecord::Migration[6.0]
  def change
    create_table :follows do |t|
      t.string :followable_type
      t.integer :followable_id
      t.integer :user_id

      t.timestamps
    end
  end
end
