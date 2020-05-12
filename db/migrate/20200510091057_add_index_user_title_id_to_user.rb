class AddIndexUserTitleIdToUser < ActiveRecord::Migration[6.0]
  def change
  	add_index :users, :user_title_id
  end
end
