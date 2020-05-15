class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :content
      t.string :notification_type
      t.string :type
      t.boolean :is_read

      t.timestamps
    end
  end
end
