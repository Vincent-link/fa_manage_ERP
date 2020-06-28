class ChangeMeetingCategoryType < ActiveRecord::Migration[6.0]
  def change
    change_column :calendars, :meeting_category, :integer, using: 'meeting_category::integer'
  end
end
