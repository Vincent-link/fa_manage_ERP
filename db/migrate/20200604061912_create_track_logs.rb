class CreateTrackLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :track_logs do |t|
      t.integer :organization_id, comment: '机构id'
      t.integer :funding_id, comment: '项目id'
      t.integer :status, comment: '状态'
      t.boolean :bp, comment: 'BP文件'
      t.boolean :nda, comment: 'NDA文件'
      t.boolean :teaser, comment: 'Teaser文件'
      t.boolean :model, comment: 'Model文件'

      t.timestamps
    end
  end
end
