class AddSomeCodeInFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :other_funding_id, :integer, comment: '外部项目的id'
    add_column :fundings, :other_funding_type, :integer, comment: '外部项目的类型'
    add_column :fundings, :category_name, :integer, comment: '其他项目类型的附带名称'
  end
end
