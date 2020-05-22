class CreateTimeLines < ActiveRecord::Migration[6.0]
  def change
    create_table :time_lines do |t|
      t.integer :funding_id, comment: '项目id'
      t.integer :status, comment: '状态'
      t.string :reason, comment: '理由'
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
