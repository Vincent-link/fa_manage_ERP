class CreateEmailBlobs < ActiveRecord::Migration[6.0]
  def change
    create_table :email_blobs do |t|
      t.integer :email_id, comment: '邮件id'
      t.integer :blob_id, comment: '文件id'
      t.integer :file_kind, comment: '文件种类'
      t.string :file_type, comment: '文件类型'
      t.string :link, comment: '链接'

      t.timestamps
    end
  end
end
