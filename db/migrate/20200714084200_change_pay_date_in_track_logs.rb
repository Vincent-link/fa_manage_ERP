class ChangePayDateInTrackLogs < ActiveRecord::Migration[6.0]
  def change
    change_column :track_logs, :pay_date, :string
  end
end
