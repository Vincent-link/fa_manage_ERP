class FixTrackLogAndDetail < ActiveRecord::Migration[6.0]
  def change
    rename_column :track_logs, :teaser, :has_teaser
    rename_column :track_logs, :bp, :has_bp
    rename_column :track_logs, :nda, :has_nda
    rename_column :track_logs, :model, :has_model

    add_column :track_log_details, :detail_type, :integer, comment: '跟进信息类型'

    add_column :track_logs, :deleted_at, :datetime
    add_index :track_logs, :deleted_at

    add_column :track_log_details, :deleted_at, :datetime
    add_index :track_log_details, :deleted_at
  end
end
