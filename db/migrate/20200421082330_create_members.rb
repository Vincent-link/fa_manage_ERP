class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.integer :organization_id, index: true
      t.string :name, comment: 'dm姓名'
      t.string :en_name, comment: 'dm英文名'
      t.string :email, comment: 'dm邮箱'
      t.string :avatar, comment: 'dm头像'
      t.string :tel, comment: 'dm电话'
      t.string :wechat, comment: 'dm微信'
      t.string :card, comment: 'dm名片'
      t.string :team, comment: 'dm团队'
      t.integer :sponsor_id, comment: '来源人id'
      t.integer :position, comment: 'dm职级'
      t.string :title, comment: '职位'
      t.boolean :is_head, comment: '是否高层', default: false
      t.boolean :is_ic, comment: '是否投委会', default: false
      t.boolean :is_president, comment: '是否最高决策人', default: false
      t.integer :address_id, comment: '地址id'
      t.string :ir_review, comment: 'ir'
      t.string :cache_sector, array: true, comment: 'dm行业缓存'
      t.string :cache_round, array: true, comment: 'dm轮次缓存'
      t.string :cache_currency, array: true, comment: 'dm币种缓存'

      t.timestamp :syn_at, comment: 'dm同步时间'
      t.timestamp :deleted_at, index: true, comment: '删除时间'

      t.timestamps
    end
  end
end
