class ChangeCurrencyInFunding < ActiveRecord::Migration[6.0]
  def change
    rename_column :fundings, :currency_id, :target_amount_currency
    add_column :fundings, :post_valuation_currency, :integer, comment: '状态转换人'
  end
end
