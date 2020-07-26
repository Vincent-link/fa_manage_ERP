class AddTrackResultToCalendar < ActiveRecord::Migration[6.0]
  def change
    add_column :calendars, :track_result, :string
    add_column :calendars, :reason, :string
  end
end
