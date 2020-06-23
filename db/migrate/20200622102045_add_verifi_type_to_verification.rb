class AddVerifiTypeToVerification < ActiveRecord::Migration[6.0]
  def change
    add_column :verifications, :verifi_type, :integer, comment: "权限审核or用户审核"
  end
end
