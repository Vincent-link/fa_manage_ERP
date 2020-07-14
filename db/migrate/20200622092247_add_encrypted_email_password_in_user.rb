class AddEncryptedEmailPasswordInUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :encrypted_email_password, :string, comment: '邮箱密码'
  end
end
