class CreateFundingCompanyContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :funding_company_contacts do |t|
      t.string :name, comment: '姓名'
      t.string :position_id, comment: '职位'
      t.string :email, comment: '邮箱'
      t.string :mobile, comment: '电话'
      t.string :wechat, comment: '微信'
      t.boolean :is_attend, comment: '是否参会'
      t.boolean :is_open, comment: '是否公开名片'
      t.string :description, comment: '简介'
      t.integer :funding_id, comment: '项目id'
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
