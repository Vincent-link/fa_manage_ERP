class RmTypeFromNotification < ActiveRecord::Migration[6.0]
  def change
    remove_column :notifications, :type
  end
end
