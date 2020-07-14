class AddFromIdInEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :emails, :from_id, :integer, comment: '发件人id'
    add_column :emails, :from_email, :integer, comment: '系统邮箱或者发件人邮箱'
  end
end
