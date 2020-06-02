class ChangeKindInFundingUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :funding_users, :kind
    add_column :funding_users, :kind, :integer, comment: '类型'
  end
end
