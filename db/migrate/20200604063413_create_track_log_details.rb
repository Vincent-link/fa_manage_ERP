class CreateTrackLogDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :track_log_details do |t|
      t.integer :track_log_id, comment: 'TrackLog的id'
      t.integer :linkable_id, comment: '约见、融资结算之类的多台关联'
      t.string :linkable_type, comment: '约见、融资结算之类的多台关联'
      t.string :content, comment: '跟进信息'
      t.integer :user_id, comment: '用户id'

      t.timestamps
    end

    add_index :track_log_details, [:linkable_type, :linkable_id]
  end
end
