class AddSomeCodeInFundings < ActiveRecord::Migration[6.0]
  def change
    change_table :fundings do |t|
      t.integer :categroy, comment: '项目类型'
      t.decimal :target_amount_min, comment: '交易金额下限'
      t.decimal :target_amount_max, comment: '交易金额上限'
      t.decimal :shares_min, comment: '出让股份上限'
      t.decimal :shares_max, comment: '出让股份下限'
      t.string :shiny_word, comment: '一句话亮点'
      t.string :com_desc, comment: '公司简介'
      t.string :products_and_business, comment: '产品与商业模式'
      t.string :financial, comment: '财务数据'
      t.string :operational, comment: '运营数据'
      t.string :market_competition, comment: '市场竞争分析'
      t.string :financing_plan, comment: '融资计划'
      t.string :other_desc, comment: '其他'
      t.integer :sources_type, comment: '融资来源类型'
      t.integer :sources_member, comment: '投资者'
      t.string :sources_detail, comment: '来源明细'
      t.integer :funding_score, comment: '项目评分'
      t.integer :round_id, comment: '轮次'
      t.integer :currency_id, comment: '币种'
      t.boolean :is_ka, comment: '是否是KA项目'
      t.boolean :is_list, comment: '是否为上市公司'
      t.string :ticker, comment: '股票信息'
      t.boolean :is_complicated, comment: '是否复杂项目'
      t.boolean :is_reportable, comment: '是否出现在周报/日报'
      t.integer :confidentiality_level, comment: '项目保密等级'
      t.string :confidentiality_reason, comment: '保密原因'

      t.remove :intro
    end
  end
end
