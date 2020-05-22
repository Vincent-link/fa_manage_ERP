class AddStatusToVerification < ActiveRecord::Migration[6.0]
  def change
    add_column :verifications, :status, :Boolean
  end
end
