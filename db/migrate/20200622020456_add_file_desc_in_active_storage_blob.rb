class AddFileDescInActiveStorageBlob < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :file_desc, :string, comment: '文件备注'
  end
end
