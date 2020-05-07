class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.string :content, comment: '内容'
      t.string :user_id, comment: '创建人id'
      t.timestamp :deleted_at, index: true
      t.string :type, index: true, comment: 'STI'

      t.timestamps
    end
  end
end
