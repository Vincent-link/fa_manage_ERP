class FundingStatusSortInUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :funding_status_sort, :integer, array: true, comment: '项目状态排序'
  end
end
