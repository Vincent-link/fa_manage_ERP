class ChangeColumnFromNotificationAndVeri < ActiveRecord::Migration[6.0]
  def change
    remove_column :notifications, :notification_type, :integer
    remove_column :verifications, :verification_type, :integer
  end
end
