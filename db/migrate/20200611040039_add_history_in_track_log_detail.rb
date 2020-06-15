class AddHistoryInTrackLogDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :track_log_details, :history, :jsonb, comment: '历史记录'
  end
end
