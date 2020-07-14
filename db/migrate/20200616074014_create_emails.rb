class CreateEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :emails do |t|
      t.integer :user_id, comment: '用户id'
      t.integer :status, comment: '状态'
      t.integer :email_template, comment: '模板value'
      t.string :title, comment: '标题'
      t.string :description, comment: '正文'
      t.string :greeting, comment: '敬语'
      t.datetime :send_at, comment: '发送时间'

      t.integer :emailable_id, comment: '关联功能id'
      t.string :emailable_type, comment: '关联功能类型'

      t.timestamps
    end

    add_index :emails, [:emailable_type, :emailable_id]
  end
end
