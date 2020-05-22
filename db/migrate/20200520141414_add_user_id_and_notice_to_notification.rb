class AddUserIdAndNoticeToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :user_id, :integer
    add_column :notifications, :notice, :json
  end
end
