class AddUserIdInActiveStorageBlob < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :user_id, :integer, comment: '上传人'
  end
end
