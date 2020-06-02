class AddOperatingDayInFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :operating_day, :date, comment: '状态更新日期'
  end
end
