class AddExecutionAtInFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :execution_at, :datetime, comment: '项目启动日期'
  end
end
