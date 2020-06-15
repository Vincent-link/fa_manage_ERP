class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.integer :pipeline_id, comment: 'pipeline_id'
      t.integer :amount, comment: '金额'
      t.integer :currency, comment: '币种'
      t.date :pay_date, comment: '付款日期'

      t.timestamps
    end
  end
end
