class CreatePipelines < ActiveRecord::Migration[6.0]
  def change
    create_table :pipelines do |t|
      t.integer :funding_id, comment: '项目id'
      t.integer :status, comment: '所处阶段'
      t.integer :est_amount, comment: '预期融资金额'
      t.integer :est_amount_currency, comment: '预期融资金额币种'
      t.integer :fee_rate, comment: '费率'
      t.integer :fee_discount, comment: '费率折扣'
      t.integer :other_amount, comment: '其他金额'
      t.integer :complete_rate, comment: '年内完成概率'
      t.integer :total_fee, comment: '项目总收入鞠策'
      t.integer :currency_rate, comment: '汇率'
      t.date :el_date, comment: '签约日期'
      t.date :est_bill_date, comment: '预计账单日期'

      t.timestamps
    end
  end
end
