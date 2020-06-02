class CreateCalendars < ActiveRecord::Migration[6.0]
  def change
    create_table :calendars do |t|
      t.string :title, comment: '日程标题'
      t.string :desc, comment: '日程描述'
      t.timestamp :started_at, comment: '开始时间'
      t.timestamp :ended_at, comment: '结束时间'
      t.integer :status, comment: '状态'
      t.integer :address_id, comment: '地点id'
      t.string :address_desc, comment: '地点详细'
      t.string :type, comment: 'STI_type', index: true
      t.integer :meeting_type, comment: '会面类型'
      t.string :meeting_category, comment: '会议类别'
      t.integer :funding_id
      t.integer :company_id
      t.integer :organization_id
      t.integer :user_id, comment: '创建人id'
      t.timestamp :deleted_at, index: true
      t.string :summary, comment: '纪要'
      t.json :summary_detail, comment: '详细纪要'
      t.integer :track_log_id, comment: 'TrackLogID'

      t.timestamps
      t.index [:deleted_at, :type]
    end
  end
end
