class ChangeVerificationStatus < ActiveRecord::Migration[6.0]
  def change
    remove_column :verifications, :status
  end
end
