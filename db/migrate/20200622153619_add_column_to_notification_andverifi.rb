class AddColumnToNotificationAndverifi < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :notification_type, :integer, comment: "通知类型"
    add_column :verifications, :verification_type, :integer, comment: "审核类型"
  end
end
