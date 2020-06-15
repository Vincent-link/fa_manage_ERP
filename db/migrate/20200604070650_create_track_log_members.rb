class CreateTrackLogMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :track_log_members do |t|
      t.integer :member_id, comment: '投资人id'
      t.integer :track_log_id, comment: 'TrackLog id'

      t.timestamps
    end
  end
end
