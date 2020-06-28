class AddDefaultToCalendarStatus < ActiveRecord::Migration[6.0]
  def change
    change_column :calendars, :status, :integer, default: 1
  end
end
