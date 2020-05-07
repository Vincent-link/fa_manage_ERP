class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name, comment: '名称'
      t.string :en_name, comment: '英文名称'
      t.string :intro, comment: '机构简介'
      t.string :logo, comment: '机构logo'
      t.string :level, comment: '级别'
      t.string :site, comment: '机构官网'
      t.string :aum, comment: '资产管理规模'
      t.string :collect_info, comment: '募资情况'
      t.string :stock_info, comment: '剩余可投金额'
      t.string :cache_tag, array: true, comment: 'dm标签'
      t.string :cache_sector, array: true, comment: 'dm行业'
      t.string :cache_round, array: true, comment: 'dm轮次'
      t.string :cache_currency, array: true, comment: 'dm币种'
      t.integer :followed_location_ids, array: true, comment: '关注地区'
      t.decimal :rmb_amount_min, precision: 12, scale: 4, comment: '人民币单笔最小金额'
      t.decimal :rmb_amount_max, precision: 12, scale: 4, comment: '人民币单笔最大金额'
      t.decimal :usd_amount_min, precision: 12, scale: 4, comment: '美元单笔最小金额'
      t.decimal :usd_amount_max, precision: 12, scale: 4, comment: '美元单笔最大金额'
      t.timestamp :syn_at, comment: 'dm同步时间'
      t.timestamp :deleted_at, comment: '删除时间'

      t.timestamps
    end
  end
end
