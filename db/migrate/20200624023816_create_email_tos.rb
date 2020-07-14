class CreateEmailTos < ActiveRecord::Migration[6.0]
  def change
    create_table :email_tos do |t|
      t.string :person_title, comment: '称谓'
      t.integer :email_to_group_id, comment: '收件人组id'
      t.integer :toable_id, comment: '收件人id'
      t.string :toable_type, comment: '收件人类型'

      t.timestamps
    end

    add_index :email_tos, [:toable_id, :toable_type]
  end
end
