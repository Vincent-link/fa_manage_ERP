class AddUserTitleIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_title_id, :integer
  end
end
