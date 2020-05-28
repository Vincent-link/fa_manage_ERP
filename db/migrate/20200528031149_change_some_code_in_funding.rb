class ChangeSomeCodeInFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :name, :string, comment: '项目名称'
    add_column :fundings, :target_amount, :decimal, comment: '交易金额'
    add_column :fundings, :share, :decimal, comment: '出让股份'
    add_column :fundings, :post_investment_valuation, :string, comment: '本轮投后估值'
    add_column :fundings, :serial_number, :string, comment: '项目编号'
    remove_column :fundings, :target_amount_min, :decimal
    remove_column :fundings, :target_amount_max, :decimal
    remove_column :fundings, :shares_min, :decimal
    remove_column :fundings, :shares_max, :decimal
  end
end
