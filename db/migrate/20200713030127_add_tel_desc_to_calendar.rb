class AddTelDescToCalendar < ActiveRecord::Migration[6.0]
  def change
    add_column :calendars, :tel_desc, :string
  end
end
