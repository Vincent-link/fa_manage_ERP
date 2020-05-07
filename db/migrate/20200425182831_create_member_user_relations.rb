class CreateMemberUserRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :member_user_relations do |t|
      t.integer :member_id
      t.integer :user_id
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
