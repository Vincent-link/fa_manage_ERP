class CreateVerifications < ActiveRecord::Migration[6.0]
  def change
    create_table :verifications do |t|
      t.string :verification_type
      t.string :status
      t.string :desc
      t.string :rejection_reason
      t.integer :sponsor
      t.integer :user_id
      t.json :verifi

      t.timestamps
    end

    add_index :user_id
    add_index :sponsor
  end
end
