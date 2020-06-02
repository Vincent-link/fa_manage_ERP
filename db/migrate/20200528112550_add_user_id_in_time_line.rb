class AddUserIdInTimeLine < ActiveRecord::Migration[6.0]
  def change
    add_column :time_lines, :user_id, :integer, comment: '状态转换人'
  end
end
