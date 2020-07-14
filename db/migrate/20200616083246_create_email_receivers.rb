class CreateEmailReceivers < ActiveRecord::Migration[6.0]
  def change
    create_table :email_receivers do |t|
      t.integer :email_id, comment: '邮件id'
      t.string :person_title, comment: '称谓'
      t.integer :kind, comment: '种类'
      t.string :email, comment: '邮箱'

      t.integer :receiverable_id, comment: '收件人等id'
      t.string :receiverable_type, comment: '收件人等类型'

      t.timestamps
    end
    add_index :email_receivers, [:receiverable_id, :receiverable_type]
  end
end
