class AddUserIdsToComment < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :relate_user_ids, :integer, array: true, comment: '参与人员'
  end
end
