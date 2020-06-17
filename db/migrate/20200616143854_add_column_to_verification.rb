class AddColumnToVerification < ActiveRecord::Migration[6.0]
  def change
    add_column :verifications, :verifyable_id, :integer
    add_column :verifications, :verifyable_type, :string
  end
end
