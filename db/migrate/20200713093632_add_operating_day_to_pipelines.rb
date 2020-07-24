class AddOperatingDayToPipelines < ActiveRecord::Migration[6.0]
  def change
    add_column :pipelines, :operating_day, :date, comment: '状态更新时间'
  end
end
