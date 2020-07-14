class DeleteLinkInEmailBlob < ActiveRecord::Migration[6.0]
  def change
    remove_column :email_blobs, :file_type, :string
    remove_column :email_blobs, :link, :string
  end
end
