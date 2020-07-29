class AddIsKunToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :is_kun, :boolean, comments: "是否是kun数据"
  end
end
