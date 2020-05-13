class AddAvatarToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :avatar, :string, comment: '用户头像'
  end
end
