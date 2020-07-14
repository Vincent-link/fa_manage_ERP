class AddStatusInEmailReceiver < ActiveRecord::Migration[6.0]
  def change
    add_column :email_receivers, :status, :integer, comment: '收件人推送状态'
  end
end
