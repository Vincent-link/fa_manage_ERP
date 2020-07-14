class CreateEmailToGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :email_to_groups do |t|
      t.integer :organization_id, comment: '机构id'
      t.integer :email_id, comment: '邮件id'
      t.integer :status, comment: '状态'

      t.timestamps
    end
  end
end
