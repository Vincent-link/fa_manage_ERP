class AddJiesuanInTrackLog < ActiveRecord::Migration[6.0]
  def change
    add_column :track_logs, :pay_date, :date, comment: '结算日期'
    add_column :track_logs, :is_fee, :boolean, comment: '是否收费'
    add_column :track_logs, :fee_rate, :float, comment: '费率'
    add_column :track_logs, :fee_discount, :float, comment: '费率折扣'
    add_column :track_logs, :amount, :float, comment: '投资金额'
    add_column :track_logs, :ratio, :float, comment: '股份比例'
  end
end
