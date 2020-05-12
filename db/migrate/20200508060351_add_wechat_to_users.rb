class AddWechatToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :wechat, :string
  end
end
