class AddCurrencyToPipeline < ActiveRecord::Migration[6.0]
  def change
    add_column :pipelines, :other_amount_currency, :integer, comment: '其他金额币种'
    add_column :pipelines, :total_fee_currency, :integer, comment: '年内预测币种'
  end
end
